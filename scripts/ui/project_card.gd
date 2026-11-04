class_name ProjectCard extends VBoxContainer


@export var project: Project


@onready var title: Label = %Title
@onready var tag_list: FlowContainer = %TagList
@onready var image_list: BoxContainer = %ImageList


func _ready() -> void:
	title.text = project.project_name

	for tag in project.tags:
		var button := preload("res://scenes/ui/tag_button.tscn").instantiate() as TagButton
		button.tag = tag
		tag_list.add_child(button)

	for image in project.images:
		var t := LazyTexture.new()
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t.path = image
		image_list.add_child(t)


func _on_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton

	if button_event and button_event.button_index == MOUSE_BUTTON_LEFT:
		Root.set_viewed_project(project)
