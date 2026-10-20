extends HBoxContainer


@onready var en: LinkButton = $En;
@onready var fr: LinkButton = $Fr;


func _ready() -> void:
	match OS.get_locale_language():
		"fr": fr.set_pressed_no_signal(true)
		_: en.set_pressed_no_signal(true)


func set_en() -> void:
	TranslationServer.set_locale("en_US")


func set_fr() -> void:
	TranslationServer.set_locale("fr_FR")
