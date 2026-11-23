class_name ProjectPage extends VBoxContainer


@export var to_hide_when_no_link: Array[Control]


var focus_on_back: Control = null


@onready var title_label: Label = %TitleLabel
@onready var link_button: Button = %LinkButton
@onready var box_container: BoxContainer = %BoxContainer
@onready var galery: BoxContainer = %Galery
@onready var long_description: RichTextLabel = %LongDescription
@onready var videos: BoxContainer = %Videos
@onready var bottom_back: Button = $BackButton2
@onready var tags_container: FlowContainer = %TagsContainer


var _tween: Tween = null
var _switch_tween: Tween = null
var _link: String


func _ready() -> void:
	if Root.mobile:
		box_container.vertical = true
		box_container.reverse_sort = true
		var sep := %SeparatorV
		sep.replace_by(preload("res://scenes/ui/separator_h.tscn").instantiate())
		sep.free()


func set_project(project: Project, switch: bool = false) -> void:
	title_label.text = project.project_name
	long_description.text = project.long_description

	if project.link.is_empty():
		for to_hide in to_hide_when_no_link:
			to_hide.visible = false
	else:
		for to_hide in to_hide_when_no_link:
			to_hide.visible = true

		link_button.text = project.link_name
		_link = project.link

	if !switch:
		modulate.a = 1.0

	for tag in project.tags:
		var button := preload("res://scenes/ui/tag_button.tscn").instantiate() as TagButton
		button.tag = tag
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tags_container.add_child(button)

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
	for child: Node in tags_container.get_children():
		child.queue_free()

	for child: Node in galery.get_children():
		child.queue_free()

	for child: Node in videos.get_children():
		child.queue_free()


func _go_back() -> void:
	Root.set_viewed_project(null, focus_on_back)


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


func _on_link_button_pressed() -> void:
	OS.shell_open(_link)
