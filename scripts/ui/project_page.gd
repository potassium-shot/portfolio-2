class_name ProjectPage extends VBoxContainer


@onready var title_label: Label = %TitleLabel
@onready var galery: BoxContainer = %Galery
@onready var long_description: RichTextLabel = %LongDescription
@onready var videos: BoxContainer = %Videos


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

	if !project.video.is_empty():
		var v: VideoPlayer = preload("res://scenes/ui/video_player.tscn").instantiate()
		v.video_id = project.video
		videos.add_child(v)

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

	for child: Node in videos.get_children():
		child.queue_free()


func _go_back() -> void:
	Root.set_viewed_project(null)
