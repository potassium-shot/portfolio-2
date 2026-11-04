class_name ProjectPage extends VBoxContainer


@onready var title_label: Label = %TitleLabel
@onready var galery: BoxContainer = %Galery


func set_project(project: Project) -> void:
	title_label.text = project.project_name

	for image in project.images:
		var t := LazyTexture.new()
		t.thumbnail = false
		t.path = image
		galery.add_child(t)


func clear() -> void:
	for child: Node in galery.get_children():
		child.queue_free()


func _go_back() -> void:
	Root.set_viewed_project(null)
