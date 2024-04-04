extends Area2D


@onready var player = get_parent().get_node("player")



func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.respawn_point = position
