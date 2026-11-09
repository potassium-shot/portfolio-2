class_name ProjectPage extends VBoxContainer


@onready var title_label: Label = %TitleLabel
@onready var galery: BoxContainer = %Galery
@onready var long_description: RichTextLabel = %LongDescription


var _tween: Tween = null


func set_project(project: Project) -> void:
	title_label.text = project.project_name
	long_description.text = project.long_description

	for image in project.images:
		var t := LazyTexture.new()
		t.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		t.thumbnail = false
		t.path = image
		galery.add_child(t)

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	long_description.visible_ratio = 0.0
	_tween.tween_property(long_description, "visible_ratio", 1.0, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)


func clear() -> void:
	for child: Node in galery.get_children():
		child.queue_free()


func _go_back() -> void:
	Root.set_viewed_project(null)
