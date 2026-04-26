extends Control

func _ready():
	$Back.grab_focus()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
