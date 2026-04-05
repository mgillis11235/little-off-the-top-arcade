extends Control

# Whether the video is in its looping phase
var is_looping = false

# Define the start time for looping (in seconds)
var loop_start_time = 10.0

var first_focus := true

func _ready():
	$MarginContainer/VBoxContainer/Story.grab_focus()



func _on_play_pressed():
	$MarginContainer.set_visible(false)
	#$Credits.set_visible(false)
	$TitleScreenMovieStart.play()
	$Select.play()
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_arcade_pressed() -> void:
	$MarginContainer.set_visible(false)
	$TitleSong.stop()
	$Select.play()
	$AnnouncerStart.play()
	#$Credits.set_visible(false)
	$TitleScreenMovieStart.play()
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://Scenes/Arcade.tscn")


func _on_credits_pressed() -> void:
	$Select.play()
	get_tree().change_scene_to_file("res://Scenes/opening_credits.tscn")


#Gamepad select sounds
func _on_story_focus_entered() -> void:
	if first_focus:
		first_focus = false
		return
	$Switch.play()


func _on_time_trial_focus_entered() -> void:
	$Switch.play()


func _on_credits_focus_entered() -> void:
	$Switch.play()
