class_name TagSelectorList extends HFlowContainer


func _enter_tree() -> void:
	var tag_list: Array[Tag] = []
	_explore_tags_in("res://data/tags", tag_list)

	for tag in tag_list:
		var button := preload("res://scenes/ui/tag_button.tscn").instantiate() as TagButton
		button.tag = tag
		add_child(button)


func _explore_tags_in(dir: String, push_to: Array[Tag]) -> void:
	for entry in ResourceLoader.list_directory(dir):
		if entry.ends_with("/"):
			_explore_tags_in(dir.path_join(entry), push_to)
		elif entry.ends_with(".tres") or entry.ends_with(".res"):
			push_to.push_back(load(dir.path_join(entry)) as Tag)


func _exit_tree() -> void:
	for child in get_children():
		child.queue_free()
