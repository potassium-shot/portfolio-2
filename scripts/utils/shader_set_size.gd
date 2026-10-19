@tool
extends Control


@onready var mat: ShaderMaterial = material as ShaderMaterial


func _enter_tree() -> void:
	resized.connect(_resized)


func _ready() -> void:
	_resized()


func _exit_tree() -> void:
	resized.disconnect(_resized)


func _resized() -> void:
	if mat:
		mat.set_shader_parameter("size", size)
