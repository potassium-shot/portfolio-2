class_name Root extends Node


static var _instance: Root
static var instance: Root:
	get:
		return _instance


@export var bg_particle_emitters: Array[CPUParticles2D]


@onready var contents: Control = $UI/UIContents
@onready var cursor: Cursor = $UI/Cursor
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var main_page: MainPage = %MainPage
@onready var project_page: ProjectPage = %ProjectPage
@onready var image_fetcher: ImageFetcher = $ImageFetcher
@onready var debug_console: ScrollContainer = $UI/DebugConsole
@onready var debug_console_lines: BoxContainer = $UI/DebugConsole/Lines


var _particle_densities: Array[float]
var _currently_viewed_project: Project = null
var _tween: Tween = null


func _enter_tree() -> void:
	_instance = self


static func print(...params: Array) -> void:
	print_many(params)


static func print_many(params: Array) -> void:
	var label := Label.new()
	label.label_settings = preload("res://resources/label_settings/normal.tres")
	label.text = "{hour}:{minute}:{second} | ".format(Time.get_time_dict_from_system()) + " ".join(params)
	instance.debug_console_lines.add_child(label)
	await instance.get_tree().process_frame
	instance.debug_console.ensure_control_visible(label)


static func set_viewed_project(project: Project) -> void:
	instance._set_viewed_project(project)


func _set_viewed_project(project: Project) -> void:
	if project == _currently_viewed_project:
		return

	_currently_viewed_project = project

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()

	var from: Control
	var to: Control

	if project:
		from = main_page
		to = project_page
	else:
		from = project_page
		to = main_page

	to.visible = true
	_tween.tween_property(from, "modulate:a", 0.0, 0.3)
	_tween.tween_callback(
		func():
			scroll_container.scroll_vertical = 0

			if project:
				project_page.set_project(project)
			else:
				main_page.show_page()
	)
	_tween.tween_property(to, "modulate:a", 1.0, 0.3)
	await _tween.finished
	from.visible = false
	get_window().update_mouse_cursor_state()

	if !project:
		project_page.clear()


func _ready() -> void:
	for p: CPUParticles2D in bg_particle_emitters:
		var size := p.emission_rect_extents * 2.0
		_particle_densities.push_back(size.x * size.y / float(p.amount))

	contents.resized.connect(_resized)
	_resized()


func _resized() -> void:
	var half := contents.size * 0.5

	for i: int in range(len(bg_particle_emitters)):
		var p := bg_particle_emitters[i]
		var density := _particle_densities[i]
		p.emission_rect_extents = half
		p.position = half
		p.amount = roundi(contents.size.x * contents.size.y / density)
