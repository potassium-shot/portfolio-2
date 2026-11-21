class_name MainPage extends VBoxContainer


@export var disable_on_mobile: Array[Control]


@onready var welcome: RichTextLabel = %WelcomeMessage


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

	if Root.mobile:
		for disable in disable_on_mobile:
			disable.visible = false


func _on_cv_button_pressed() -> void:
	OS.shell_open("https://images.potassium-shot.eu/cv.pdf?raw=true&download=true&file_name=zana-toni_cv_2026-11-20.pdf")


func _on_welcome_message_meta_clicked(meta: Variant) -> void:
	var json: Dictionary = JSON.parse_string(meta)

	if "project" in json:
		Root.set_viewed_project(load(json["project"]))
	elif "url" in json:
		OS.shell_open(json["url"])
