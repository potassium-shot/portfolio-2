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


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	await get_tree().process_frame
	Root.instance.tag_manager.tag_filter_changed.connect(_tag_filter_changed)


func _exit_tree() -> void:
	if Root.instance.tag_manager.tag_filter_changed.is_connected(_tag_filter_changed):
		Root.instance.tag_manager.tag_filter_changed.disconnect(_tag_filter_changed)


func _tag_filter_changed(tags: Array[Tag]) -> void:
	set_pressed_no_signal(tag in tags)


func _toggled(toggled_on: bool) -> void:
	if Engine.is_editor_hint():
		return

	if toggled_on:
		Root.instance.tag_manager.add_tag(tag)
	else:
		Root.instance.tag_manager.remove_tag(tag)


func _update_tag() -> void:
	for style in ["normal", "hover", "pressed"]:
		remove_theme_stylebox_override(style)
		var box := get_theme_stylebox(style).duplicate() as StyleBoxFlat
		box.border_color *= tag.color
		box.bg_color *= tag.color
		add_theme_stylebox_override(style, box)

	text = tag.tag_name
