extends HBoxContainer


@onready var work_list: BoxContainer = %WorkList
@onready var projects_list: BoxContainer = %ProjectsList


func _ready() -> void:
	var project_list: Array[Project] = []
	_explore_projects_in("res://data/projects", project_list)

	project_list.sort_custom(func(a: Project, b: Project) -> bool: return a.order > b.order)

	for project in project_list:
		var card := preload("res://scenes/ui/project_card.tscn").instantiate() as ProjectCard
		card.project = project

		var parent: BoxContainer

		match project.type:
			Project.ProjectType.Project:
				parent = projects_list
			Project.ProjectType.Work:
				parent = work_list

		parent.add_child(card)


func _explore_projects_in(dir: String, push_to: Array[Project]) -> void:
	for entry in ResourceLoader.list_directory(dir):
		if entry.ends_with("/"):
			_explore_projects_in(dir.path_join(entry), push_to)
		elif entry.ends_with(".tres") or entry.ends_with(".res"):
			push_to.push_back(load(dir.path_join(entry)) as Project)
