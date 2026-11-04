class_name Project extends Resource


enum ProjectType {
	Project,
	Work,
}


@export var project_name: String = "Project"
@export var type: ProjectType = ProjectType.Project
@export var tags: Array[Tag]
@export var order: int = 0
@export var images: Array[String]
