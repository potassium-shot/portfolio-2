class_name ProjectCard extends PanelContainer


@export var project: Project


@onready var title: Label = %Title
@onready var desc: Label = %Desc
@onready var tag_list: FlowContainer = %TagList
@onready var image_list: BoxContainer = %ImageList
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var background: ColorRect = %Background


var _background_tween: Tween = null
var _autoscroll_tween: Tween = null


func _ready() -> void:
	if Root.mobile:
		image_list.vertical = true
	else:
		image_list.custom_minimum_size.x = 400.0

	title.text = project.project_name
	desc.text = project.short_description

	for tag in project.tags:
		var button := preload("res://scenes/ui/tag_button.tscn").instantiate() as TagButton
		button.tag = tag
		tag_list.add_child(button)

	if project.images.is_empty():
		image_list.visible = false
	else:
		for image in project.images:
			var t := LazyTexture.new()
			t.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			t.custom_minimum_size.y = 256.0
			t.path = image
			image_list.add_child(t)

	await get_tree().process_frame
	Root.instance.tag_manager.tag_filter_changed.connect(_tag_filter_changed)


func _exit_tree() -> void:
	if Root.instance.tag_manager.tag_filter_changed.is_connected(_tag_filter_changed):
		Root.instance.tag_manager.tag_filter_changed.disconnect(_tag_filter_changed)


func _tag_filter_changed(tags: Array[Tag]) -> void:
	var included = tags.all(func(tag: Tag) -> bool: return tag in project.tags)
	modulate.a = 1.0 if included else 0.06


var _pressed_coords: Vector2 = Vector2.ZERO


func _on_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton

	if button_event and button_event.button_index == MOUSE_BUTTON_LEFT:
		if button_event.is_released():
			if _pressed_coords.distance_squared_to(button_event.position) < 1.0 * 1.0:
				Root.set_viewed_project(project, self)
		else:
			_pressed_coords = button_event.position


func _on_mouse_entered() -> void:
	const COLOR: Color = Color(0.591, 1.486, 0.964)
	self_modulate = COLOR
	title.modulate = COLOR

	if _background_tween and _background_tween.is_running():
		_background_tween.kill()

	_background_tween = create_tween()
	_background_tween.tween_property(background, "self_modulate:a", 1.0, 0.15)


func _on_mouse_exited() -> void:
	self_modulate = Color.WHITE
	title.modulate = Color.WHITE

	if _background_tween and _background_tween.is_running():
		_background_tween.kill()

	_background_tween = create_tween()
	_background_tween.tween_property(background, "self_modulate:a", 0.0, 0.15)


func _on_scroll_container_resized() -> void:
	_update_horizontal_scroll()


func _on_image_list_resized() -> void:
	_update_horizontal_scroll()


func _update_horizontal_scroll() -> void:
	if !is_node_ready():
		return

	if _autoscroll_tween and _autoscroll_tween.is_running():
		_autoscroll_tween.kill()

	if image_list.size.x <= scroll_container.size.x:
		scroll_container.size_flags_horizontal = SIZE_SHRINK_CENTER
		scroll_container.custom_minimum_size.x = image_list.size.x
	else:
		scroll_container.size_flags_horizontal = SIZE_FILL
		scroll_container.custom_minimum_size.x = 0.0
		scroll_container.scroll_horizontal = 0

		_autoscroll_tween = create_tween()
		var distance := image_list.size.x - scroll_container.size.x
		_autoscroll_tween.tween_property(scroll_container, "scroll_horizontal", distance, distance / 90.0)
		_autoscroll_tween.tween_interval(2.0)
		_autoscroll_tween.tween_property(scroll_container, "scroll_horizontal", 0.0, 0.3)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_autoscroll_tween.tween_interval(1.0)
		_autoscroll_tween.set_loops()
