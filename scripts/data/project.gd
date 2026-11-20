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
@export var short_description: String
@export var long_description: String
@export var video: String = ""
@export var video_thumbnail: String = ""
@export var link: String = ""
@export var link_name: String = ""
@export var bottom_back_visible: bool = true
