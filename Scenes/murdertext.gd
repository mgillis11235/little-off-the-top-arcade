extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameMusic.get_node("AlpacaWtfWithSolo").stop()
	$MoonSprite.play("default")
	#$Whimper_Sound.play()
	await get_tree().create_timer(2).timeout
	$RichTextLabel2.set_visible(true)
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(5).timeout
	$RichTextLabel2.set_visible(false)
	$RichTextLabel3.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel3.set_visible(false)
	$RichTextLabel9.set_visible(true)
	await get_tree().create_timer(6.0).timeout
	$RichTextLabel9.set_visible(false)
	$RichTextLabel4.set_visible(true)
	await get_tree().create_timer(4.5).timeout
	$RichTextLabel4.set_visible(false)
	$RichTextLabel4b.set_visible(true)
	await get_tree().create_timer(4.5).timeout
	$RichTextLabel4b.set_visible(false)
	$RichTextLabel5.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel5.set_visible(false)
	$Button.set_visible(true)
	$Button2.set_visible(true)
	
	#Now buttons appear


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ToolLeft") and Input.is_action_pressed("ToolRight") and Input.is_action_pressed("Interact"):
		get_tree().change_scene_to_file("res://Scenes/score_screen.tscn")
	pass
		
		#$TextPopups/NeedPanel.set_visible(false)
		#$TextPopups/SadPanel.set_visible(true)
		#await get_tree().create_timer(4.0).timeout
		#$TextPopups/SadPanel.set_visible(false)




func _on_button_pressed() -> void:
	$Button.set_visible(false)
	$Button2.set_visible(false)
	
	$RichTextLabel8.set_visible(true)
	$Car_Door.play()
	await get_tree().create_timer(2.0).timeout
	$Car_Engine.play()
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel8.set_visible(false)
	$RichTextLabel11.set_visible(true)
	$Desert_Tone.play()
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel11.set_visible(false)
	$RichTextLabel10.set_visible(true)
	$MoonSprite.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel10.set_visible(false)
	$RichTextLabel10b.set_visible(true)	
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel10b.set_visible(false)
	$Button3.set_visible(true)	
	$Button4.set_visible(true)
	
	
	#Car door slammed
	#Car engine
	#"The body is heavy"
	#Play grasshopper sounds
	#Play shovel sounds
	#Moon appears


func _on_button_2_pressed() -> void:
	$Button.set_visible(false)
	$Button2.set_visible(false)
	
	$RichTextLabel8.set_visible(true)
	$Car_Door.play()
	await get_tree().create_timer(2.0).timeout
	$Car_Engine.play()
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel8.set_visible(false)
	$RichTextLabel11.set_visible(true)
	$Desert_Tone.play()
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel11.set_visible(false)
	$RichTextLabel10.set_visible(true)
	$MoonSprite.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel10.set_visible(false)
	$RichTextLabel10b.set_visible(true)	
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel10b.set_visible(false)
	$Button3.set_visible(true)	
	$Button4.set_visible(true)
	
	
func _on_button3_pressed() -> void:
	$RichTextLabel10b.set_visible(false)
	$Button3.set_visible(false)	
	$Button4.set_visible(false)
	$RichTextLabel13.set_visible(true)
	$Digging_Noise.play()
	await get_tree().create_timer(14.0).timeout
	$RichTextLabel13.set_visible(false)
	$RichTextLabel14.set_visible(true)



#Play digging noise
#You dig and dig and dig. You dig and dig and dig.
#Last purple prose and just linger on that.
#Hard cut back to barber shop
	#Car door slammed
	#Car engine
	#"The body is heavy"
	#Play grasshopper sounds
	#Play shovel sounds
	#Moon appears


func _on_button_4_pressed() -> void:
	$RichTextLabel10b.set_visible(false)
	$Button3.set_visible(false)	
	$Button4.set_visible(false)
	$RichTextLabel12.set_visible(true)
	$Desert_Tone.stop()
	$Digging_Noise.play()
	
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12b.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12c.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12d.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$Digging_Noise.stop()
	
	$RichTextLabel12b.set_visible(false)
	$RichTextLabel12.set_visible(false)
	$RichTextLabel12c.set_visible(false)
	$RichTextLabel12d.set_visible(false)
	
	$Desert_Tone.play()
	#$AudioStreamPlayer2D.stop()
	$RichTextLabel14.set_visible(true)
	await get_tree().create_timer(10.0).timeout
	get_tree().change_scene_to_file("res://Scenes/score_screen.tscn")


func _on_button_3_pressed() -> void:
	$RichTextLabel10.set_visible(false)
	$Button3.set_visible(false)	
	$Button4.set_visible(false)
	$RichTextLabel12.set_visible(true)
	$Desert_Tone.stop()
	
	$Digging_Noise.play()
	
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12b.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12c.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$RichTextLabel12d.set_visible(true)
	await get_tree().create_timer(4.0).timeout
	$Digging_Noise.stop()
	
	$Desert_Tone.play()
	#$AudioStreamPlayer2D.stop()
	
	$RichTextLabel12b.set_visible(false)
	$RichTextLabel12.set_visible(false)
	$RichTextLabel12c.set_visible(false)
	$RichTextLabel12d.set_visible(false)
	$RichTextLabel14.set_visible(true)
	await get_tree().create_timer(10.0).timeout
	get_tree().change_scene_to_file("res://Scenes/score_screen.tscn")
