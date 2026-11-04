@tool
class_name LazyTexture extends TextureRect


const ADDRESS_FORMAT_NORMAL: String = "/portfolio/{path}"
const ADDRESS_FORMAT_THUMBNAIL: String = "/portfolio/{path}?max_width={width}&max_height={height}"
const DEFAULT_ALPHA: float = 0.7
const TWEEN_SPEED: float = 0.15


var _path: String
@export var path: String:
	get:
		return _path

	set(value):
		if value == _path:
			return

		_path = value

		if is_node_ready() and !Engine.is_editor_hint():
			_update_image(false)

@export var thumbnail: bool = true

static var _update_lock: Array[LazyTexture]

var _topmost_texture: TextureRect = null
var _tween: Tween = null


@export_tool_button("Test Editor") var update_test_editor: Callable = _update_image


func _init() -> void:
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return

	_topmost_texture = TextureRect.new()
	_topmost_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_topmost_texture.anchor_bottom = 1.0
	_topmost_texture.anchor_top = 0.0
	_topmost_texture.anchor_left = 0.0
	_topmost_texture.anchor_right = 1.0
	_topmost_texture.z_index = 500
	_topmost_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_topmost_texture.self_modulate.a = DEFAULT_ALPHA
	add_child(_topmost_texture)

	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	resized.connect(_resized)


func _exit_tree() -> void:
	if _topmost_texture:
		_topmost_texture.queue_free()

	if mouse_entered.is_connected(_mouse_entered):
		mouse_entered.disconnect(_mouse_entered)

	if mouse_exited.is_connected(_mouse_exited):
		mouse_exited.disconnect(_mouse_exited)

	if resized.is_connected(_resized):
		resized.disconnect(_resized)


func _ready() -> void:
	if !Engine.is_editor_hint():
		await get_tree().process_frame
		_update_image(false)


func _mouse_entered() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_topmost_texture, "self_modulate:a", 1.0, TWEEN_SPEED)
	Root.instance.cursor.topmost_counter += 1


func _mouse_exited() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_topmost_texture, "self_modulate:a", DEFAULT_ALPHA, TWEEN_SPEED)
	Root.instance.cursor.topmost_counter -= 1


func _resized() -> void:
	if thumbnail:
		var current_size = Vector2.ZERO

		if texture:
			current_size = texture.get_size()

		if size.x > current_size.x or size.y > current_size.y:
			_update_image(false)


func _update_image(force: bool) -> void:
	if path.is_empty() or (thumbnail and (size.x == 0 or size.y == 0)):
		texture = null
		_topmost_texture.texture = null
		return

	if !_update_lock.is_empty() and !force:
		_update_lock.push_back(self)
		return

	if !force:
		_update_lock.push_back(self)

	var good := false

	var client := HTTPClient.new()
	client.connect_to_host("https://images.potassium-shot.eu")

	while client.get_status() in [HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING]:
		client.poll()
		await get_tree().process_frame

	if client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT]:
		printerr("Error while connecting to image server: %d" % client.get_status())
	else:
		var address_format: String = ADDRESS_FORMAT_THUMBNAIL if thumbnail else ADDRESS_FORMAT_NORMAL
		var r := client.request(HTTPClient.METHOD_GET, address_format.format({"path": path, "width": roundi(size.x), "height": roundi(size.y)}), [])

		if r != OK:
			printerr("Could not request image '%s': %s" % [path, error_string(r)])
		else:
			while client.get_status() in [HTTPClient.STATUS_REQUESTING]:
				client.poll()
				await get_tree().process_frame

			if client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT]:
				printerr("Error while connected to image server: %d" % client.get_status())
			elif client.get_response_code() != HTTPClient.RESPONSE_OK:
				printerr("Image server responded with code %d." % client.get_response_code())
			else:
				var data := PackedByteArray()
				const LIMIT := 10 * 1024 * 1024
				var wait_counter := 0

				while client.get_status() == HTTPClient.STATUS_BODY:
					data.append_array(client.read_response_body_chunk())
					client.poll()
					wait_counter += 1

					if wait_counter >= 5:
						wait_counter = 0
						await get_tree().process_frame

					if len(data) > LIMIT:
						client.close()
						_update_lock.pop_front()
						assert(false, "Image size exeeded limit of 10MB.")

				var image := Image.new()
				image.load_png_from_buffer(data)

				texture = ImageTexture.create_from_image(image)
				_topmost_texture.texture = texture
				good = true

	client.close()
	_update_lock.pop_front()

	if !good:
		texture = null
		_topmost_texture.texture = null

	if !_update_lock.is_empty():
		_update_lock[0]._update_image(true)
