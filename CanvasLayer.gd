extends CanvasLayer

@onready var main = $Main

func _on_button_play_pressed():
	get_tree().change_scene_to_file("res://Levels/room_1.tscn")


func _on_button_quit_pressed():
	get_tree().quit()
