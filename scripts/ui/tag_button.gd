@tool
class_name TagButton extends Button


var _tag: Tag
@export var tag: Tag:
	get:
		return _tag

	set(value):
		_tag = value

		if is_inside_tree():
			_update_tag()


func _enter_tree() -> void:
	_update_tag()


func _update_tag() -> void:
	for style in ["normal", "hover", "pressed"]:
		remove_theme_stylebox_override(style)
		var box := get_theme_stylebox(style).duplicate() as StyleBoxFlat
		box.border_color *= tag.color
		box.bg_color *= tag.color
		add_theme_stylebox_override(style, box)

	text = tag.tag_name
