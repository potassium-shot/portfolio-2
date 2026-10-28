class_name Cursor extends TextureRect


const CLICK_FX: PackedScene = preload("res://scenes/fx/wave_fx.tscn")


@export var highlighted_color: Color


var _topmost_counter: int = 0
var topmost_counter: int:
	get:
		return _topmost_counter

	set(value):
		if value == _topmost_counter:
			return

		_topmost_counter = value

		z_index = 600 if value > 0 else 100


@onready var glow: TextureRect = $Glow


func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_window().mouse_entered.connect(_mouse_entered)
	get_window().mouse_exited.connect(_mouse_exited)

	if DisplayServer.is_touchscreen_available():
		visible = false


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	position = get_global_mouse_position()

	if Input.get_current_cursor_shape() == 2:
		modulate = highlighted_color
		glow.visible = true
	else:
		modulate = Color.WHITE
		glow.visible = false

	if Input.is_action_just_pressed("click"):
		var fx: Control = CLICK_FX.instantiate()
		Root.instance.contents.add_child(fx)
		fx.position = position - fx.size * 0.5


func _mouse_entered() -> void:
	if !DisplayServer.is_touchscreen_available():
		visible = true


func _mouse_exited() -> void:
	visible = false
