extends ColorRect


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	material = material.duplicate()
	animation_player.play("wave")
	await animation_player.animation_finished
	queue_free()
