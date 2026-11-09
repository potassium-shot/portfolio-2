class_name LazyTexture extends TextureRect


const PLACEHOLDER: Texture2D = preload("res://textures/loading.png")


const DEFAULT_ALPHA: float = 0.7
const TWEEN_SPEED: float = 0.15


var path: String

@export var thumbnail: bool = true

var _topmost_texture: TextureRect = null
var _tween: Tween = null
var _cancel_token: Callable = func(): pass
var _frame_requested: int = -2


func _init() -> void:
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _enter_tree() -> void:
	texture = PLACEHOLDER

	_topmost_texture = TextureRect.new()
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
	visibility_changed.connect(_visibility_changed)


func _exit_tree() -> void:
	if _topmost_texture:
		_topmost_texture.queue_free()

	if mouse_entered.is_connected(_mouse_entered):
		mouse_entered.disconnect(_mouse_entered)

	if mouse_exited.is_connected(_mouse_exited):
		mouse_exited.disconnect(_mouse_exited)

	if resized.is_connected(_resized):
		resized.disconnect(_resized)

	if visibility_changed.is_connected(_visibility_changed):
		visibility_changed.disconnect(_visibility_changed)

	_cancel_token.call()


func _visibility_changed() -> void:
	if !is_node_ready():
		return

	if is_visible_in_tree():
		if thumbnail:
			var current_size = Vector2.ZERO

			if texture:
				current_size = texture.get_size()

			if size.x > current_size.x or size.y > current_size.y:
				_update_image()
		elif !texture:
			_update_image()
	else:
		_cancel_token.call()


func _ready() -> void:
	_topmost_texture.expand_mode = expand_mode;
	_topmost_texture.stretch_mode = stretch_mode
	await get_tree().process_frame
	_update_image()


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
	if is_node_ready() and thumbnail:
		var current_size = Vector2.ZERO

		if texture:
			current_size = texture.get_size()

		if size.x > current_size.x or size.y > current_size.y:
			_update_image()


func _update_image() -> void:
	var frame := Engine.get_process_frames()

	if (thumbnail and (size.x == 0 or size.y == 0)) or _frame_requested == frame or _frame_requested + 1 == frame:
		return

	_frame_requested = frame

	_cancel_token = Root.instance.image_fetcher.fetch_image(
		func(image: ImageTexture):
			texture = image
			_topmost_texture.texture = image,
		func():
			await get_tree().create_timer(1.0).timeout
			_update_image(),
		path,
		Vector2i(size) if thumbnail else Vector2i.ZERO,
	)
