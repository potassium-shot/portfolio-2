class_name MainPage extends VBoxContainer


@onready var welcome: Label = %WelcomeMessage


var _tween: Tween = null


func show_page() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	welcome.visible_ratio = 0.0
	_tween.tween_property(welcome, "visible_ratio", 1.0, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)


func _ready() -> void:
	show_page()
