extends Node

var smBubble = preload("res://Nodes/speech_bubble_small.tscn")
var lgBubble = preload("res://Nodes/speech_bubble_large.tscn")

var currentBubble = null

func remove_bubble():
	if currentBubble != null:
		currentBubble.destroy_bubble()

func create_bubble(place: Vector2, flip: bool, size: int, text: String, timeLimit: float, llamaName: String):
	if currentBubble != null:
		currentBubble.destroy_bubble()
		await get_tree().create_timer(.5).timeout
	
	$SpeechBubbleHolder.position = place
	
	if size == 0:
		currentBubble = smBubble.instantiate()
	elif size == 1:
		currentBubble = lgBubble.instantiate()
	
	$SpeechBubbleHolder.add_child(currentBubble)
	
	if flip:
		currentBubble.flip_h = true
	
	currentBubble.get_node("SpeechBubbleLabel").text = text
	currentBubble.get_node("NameLabel").text = llamaName
	
	if timeLimit != 0:
		await get_tree().create_timer(timeLimit).timeout
		if currentBubble != null:
			currentBubble.destroy_bubble()
