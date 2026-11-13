class_name VideoPlayer extends LazyTexture


@export var video_id: String


func _on_button_pressed() -> void:
	Root.instance.web.show_video(video_id)
