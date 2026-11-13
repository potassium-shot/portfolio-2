class_name TagManager extends Node


var tag_filter: Array[Tag]


signal tag_filter_changed(tags: Array[Tag])


func add_tag(tag: Tag) -> void:
	tag_filter.push_back(tag)
	tag_filter_changed.emit(tag_filter)


func remove_tag(tag: Tag) -> void:
	tag_filter.erase(tag)
	tag_filter_changed.emit(tag_filter)


func clear_tags() -> void:
	tag_filter.clear()
	tag_filter_changed.emit(tag_filter)
