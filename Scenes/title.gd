extends Control

# Whether the video is in its looping phase
var is_looping = false

# Define the start time for looping (in seconds)
var loop_start_time = 10.0

func _on_play_pressed():
	$MarginContainer.set_visible(false)
	#$Credits.set_visible(false)
	$TitleScreenMovieStart.play()
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_arcade_pressed() -> void:
	$MarginContainer.set_visible(false)
	#$Credits.set_visible(false)
	$TitleScreenMovieStart.play()
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Arcade.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/opening_credits.tscn")
