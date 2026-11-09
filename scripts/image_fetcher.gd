class_name ImageFetcher extends Node


const ADDRESS_FORMAT_NORMAL: String = "/portfolio/{path}"
const ADDRESS_FORMAT_THUMBNAIL: String = "/portfolio/{path}?max_width={width}&max_height={height}"


@export var max_parallel: int = 5
@export var clock_time: float = 0.2


class ParallelClient extends RefCounted:
	var index: int
	var client: HTTPClient
	var request: Request = null


class Request extends RefCounted:
	var done_callback: Callable
	var error_callback: Callable
	var path: String
	var max_size: Vector2i
	var cancelled: bool = false
	var client: ParallelClient = null


var _clients: Array[ParallelClient]
var _queued_requests: Dictionary[String, Request]
var _clock: Timer


func _ready() -> void:
	_clock = Timer.new()
	_clock.wait_time = clock_time
	_clock.autostart = true
	add_child(_clock)
	_clock.timeout.connect(_update)


	for i in range(max_parallel):
		_clients.push_back(null)
		_refresh_client(i)


func _update() -> void:
	if !_queued_requests.is_empty():
		var to_delete: Array[String]

		for path in _queued_requests:
			var req := _queued_requests[path]

			if req.cancelled:
				to_delete.push_back(path)
			else:
				var c := _find_first_available_client()

				if c:
					c.request = req
					_fetch_image_impl_handle_errors(req, c)
					to_delete.push_back(path)

		for path in to_delete:
			_queued_requests.erase(path)


## Schedules an image for being fetched. The first argument is a callback that gets called when the image
## has been aquired, with the image as an ImageTexture as only argument.
## The return value of this function is a cancel callback. Call it, and the image fetching will be cancelled.
func fetch_image(done_callback: Callable, error_callback: Callable, path: String, max_size: Vector2i = Vector2i.ZERO) -> Callable:
	if path.is_empty():
		done_callback.call(null)
		return func(): pass

	var req := Request.new()
	req.done_callback = done_callback
	req.error_callback = error_callback
	req.path = path
	req.max_size = max_size

	_fetch_image_impl_handle_errors(req, null)

	return func():
		req.cancelled = true


func _fetch_image_impl_handle_errors(req: Request, c: ParallelClient) -> void:
	var result := await _fetch_image_impl(req, c)
	var c_index := -1

	if req.client:
		c_index = req.client.index
		req.client.request = null
		req.client = null

	if result != OK:
		req.error_callback.call()

	if c_index != -1:
		_refresh_client(c_index)


func _fetch_image_impl(req: Request, c: ParallelClient) -> Error:
	if !c:
		c = _find_first_available_client()

		if !c:
			_queued_requests[req.path] = req
			return OK

	c.request = req
	req.client = c

	while c.client.get_status() in [HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING]:
		await _clock.timeout

		if req.cancelled:
			return OK

	if c.client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT]:
		printerr("Error while connecting to image server: %d" % c.client.get_status())
		return Error.ERR_CANT_CONNECT

	var address_format: String = ADDRESS_FORMAT_THUMBNAIL if req.max_size != Vector2i.ZERO else ADDRESS_FORMAT_NORMAL
	var r := c.client.request(
		HTTPClient.METHOD_GET,
		address_format.format({"path": req.path, "width": roundi(req.max_size.x), "height": roundi(req.max_size.y)}),
		[],
	)

	if r != OK:
		printerr("Could not request image '%s': %s" % [req.path, error_string(r)])
		return Error.ERR_QUERY_FAILED

	while c.client.get_status() in [HTTPClient.STATUS_REQUESTING]:
		await _clock.timeout

		if req.cancelled:
			return OK

	if c.client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT]:
		printerr("Error while connected to image server: %d" % c.client.get_status())
		return Error.ERR_CANT_CONNECT
	elif c.client.get_response_code() != HTTPClient.RESPONSE_OK:
		printerr("Image server responded with code %d." % c.client.get_response_code())
		return Error.ERR_QUERY_FAILED

	var data := PackedByteArray()
	const LIMIT := 10 * 1024 * 1024
	var wait_counter := 0

	while c.client.get_status() == HTTPClient.STATUS_BODY:
		data.append_array(c.client.read_response_body_chunk())
		c.client.poll()
		wait_counter += 1

		if wait_counter >= 5:
			wait_counter = 0
			await _clock.timeout

			if req.cancelled:
				return OK

		if len(data) > LIMIT:
			printerr("Image size exeeded limit of 10MB.")
			return Error.ERR_INVALID_DATA

	var image := Image.new()
	image.load_png_from_buffer(data)

	if !req.cancelled:
		req.done_callback.call(ImageTexture.create_from_image(image))

	return OK


func _find_first_available_client() -> ParallelClient:
	for c in _clients:
		if c and !c.request:
			return c

	return null


func _refresh_client(index: int) -> void:
	var c := ParallelClient.new()
	c.index = index
	c.client = HTTPClient.new()
	c.client.connect_to_host("https://images.potassium-shot.eu")

	var old := _clients[index]

	if old and _clock.timeout.is_connected(old.client.poll):
		_clock.timeout.disconnect(old.client.poll)

	_clock.timeout.connect(c.client.poll)
	_clients[index] = c
