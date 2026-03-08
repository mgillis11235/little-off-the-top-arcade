extends Node

var smBubble = preload("res://Nodes/speech_bubble_small.tscn")
var lgBubble = preload("res://Nodes/speech_bubble_large.tscn")

var currentBubble = null
var dialogue_running := false


func remove_bubble():
	if currentBubble != null:
		currentBubble.destroy_bubble()
		currentBubble = null


func stop_dialogue():
	dialogue_running = false
	remove_bubble()


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
			currentBubble = null


func play_dialogue(lines, speaker_name: String, total_time: float):

	stop_dialogue()

	if lines == null:
		return

	var dialogue_lines: Array

	if typeof(lines) == TYPE_STRING:
		dialogue_lines = [lines]
	elif typeof(lines) == TYPE_ARRAY:
		dialogue_lines = lines
	else:
		return

	if dialogue_lines.is_empty():
		return

	dialogue_running = true

	var segment_time = total_time / float(dialogue_lines.size())

	for line in dialogue_lines:

		if !dialogue_running:
			return

		var parent = get_parent()

		if parent.get("llamaTalkSFX") != null:
			var sfx = parent.llamaTalkSFX
			if sfx.size() > 0:
				sfx.pick_random().play()

		create_bubble(
			Vector2(-177, -78),
			false,
			0,
			line,
			segment_time,
			speaker_name
		)

	await get_tree().create_timer(segment_time).timeout

	dialogue_running = false
