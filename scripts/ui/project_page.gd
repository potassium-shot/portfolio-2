class_name ProjectPage extends VBoxContainer


@onready var title_label: Label = %TitleLabel
@onready var galery: BoxContainer = %Galery
@onready var long_description: RichTextLabel = %LongDescription


func set_project(project: Project) -> void:
	title_label.text = project.project_name
	long_description.text = project.long_description

	for image in project.images:
		var t := LazyTexture.new()
		t.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		t.thumbnail = false
		t.path = image
		galery.add_child(t)


func clear() -> void:
	for child: Node in galery.get_children():
		child.queue_free()


func _go_back() -> void:
	Root.set_viewed_project(null)
