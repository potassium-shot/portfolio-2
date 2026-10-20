class_name Root extends Node


static var _instance: Root
static var instance: Root:
	get:
		return _instance


@onready var contents: Control = $UI/UIContents


func _enter_tree() -> void:
	_instance = self
