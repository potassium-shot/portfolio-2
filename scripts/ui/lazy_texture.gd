@tool
class_name LazyTexture extends TextureRect


const ADDRESS_FORMAT: String = "/portfolio/{path}?max_width={width}&max_height={height}"


var _path: String
@export var path: String:
	get:
		return _path

	set(value):
		if value == _path:
			return

		_path = value

		if is_node_ready() and !Engine.is_editor_hint():
			_update_image()

var _update_lock: bool = false

var _topmost_texture: TextureRect = null


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
	_topmost_texture.self_modulate.a = 0.0
	add_child(_topmost_texture)

	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _exit_tree() -> void:
	if _topmost_texture:
		_topmost_texture.queue_free()

	if mouse_entered.is_connected(_mouse_entered):
		mouse_entered.connect(_mouse_entered)

	if mouse_exited.is_connected(_mouse_exited):
		mouse_exited.connect(_mouse_exited)


func _ready() -> void:
	if !Engine.is_editor_hint():
		await get_tree().process_frame
		_update_image()


func _mouse_entered() -> void:
	_topmost_texture.self_modulate.a = 1.0
	Root.instance.cursor.topmost_counter += 1


func _mouse_exited() -> void:
	_topmost_texture.self_modulate.a = 0.0
	Root.instance.cursor.topmost_counter -= 1


func _update_image() -> void:
	if path.is_empty() or size.x == 0 or size.y == 0:
		texture = null
		_topmost_texture.texture = null
		return

	if _update_lock:
		return

	_update_lock = true

	var good := false

	var client := HTTPClient.new()
	client.connect_to_host("https://images.potassium-shot.eu")

	while client.get_status() in [HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING]:
		client.poll()
		await get_tree().process_frame

	if client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT]:
		printerr("Error while connecting to image server: %d" % client.get_status())
	else:
		var r := client.request(HTTPClient.METHOD_GET, ADDRESS_FORMAT.format({"path": path, "width": roundi(size.x), "height": roundi(size.y)}), [])

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
				var l := client.get_response_body_length()
				var data := client.read_response_body_chunk()

				while len(data) < l:
					data.append_array(client.read_response_body_chunk())

				var image := Image.new()
				image.load_png_from_buffer(data)

				texture = ImageTexture.create_from_image(image)
				_topmost_texture.texture = texture
				good = true

	client.close()
	_update_lock = false

	if !good:
		texture = null
		_topmost_texture.texture = null
