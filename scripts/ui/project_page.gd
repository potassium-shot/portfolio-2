class_name ProjectPage extends VBoxContainer


@onready var title_label: Label = %TitleLabel
@onready var galery: BoxContainer = %Galery
@onready var long_description: RichTextLabel = %LongDescription
@onready var videos: BoxContainer = %Videos
@onready var bottom_back: Button = $BackButton2


var _tween: Tween = null
var _switch_tween: Tween = null


func set_project(project: Project, switch: bool = false) -> void:
	title_label.text = project.project_name
	long_description.text = project.long_description

	if !switch:
		modulate.a = 1.0

	for image in project.images:
		var t := LazyTexture.new()
		t.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		t.thumbnail = false
		t.path = image
		galery.add_child(t)

	if !project.video.is_empty():
		var v: VideoPlayer = preload("res://scenes/ui/video_player.tscn").instantiate()
		v.video_id = project.video
		v.path = project.video_thumbnail
		videos.add_child(v)

	bottom_back.visible = project.bottom_back_visible

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


func _on_long_description_meta_clicked(meta: Variant) -> void:
	if _switch_tween and _switch_tween.is_running():
		return

	var json: Dictionary = JSON.parse_string(meta)

	if "project" in json:
		_switch_tween = create_tween()
		_switch_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_switch_tween.tween_callback(clear)
		_switch_tween.tween_callback(set_project.bind(true).bind(load(json["project"])))
		_switch_tween.tween_property(self, "modulate:a", 1.0, 0.3)
