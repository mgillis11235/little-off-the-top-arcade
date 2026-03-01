extends BaseGameManager

class_name Game_Manager_Arcade

var murdered: bool

enum Sequence {NONE, START, GAMEPLAY, SCORING, SPIT, POST, WRAP}
var seqCurrent: Sequence:
	set(value):
		seqCurrent = value
		sequence_update.emit(value)

var blockInput: bool
var tutorialOverride: bool

var currentRef

var currentCustomerIndex: int = -1

var toolMode: Tool.Modes

signal sequence_update(seq: Sequence)

@onready var header_label: Label = $TutorialHolder/HeaderLabel
@onready var tutorial_label: Label = $TutorialHolder/TutorialLabel
@onready var tutorial_anim: AnimationPlayer = $TutorialHolder/TutorialAnim
@onready var game_time_label = $GameTimeLabel
@onready var game_time_timer = $GameTimeLabel/GameTimeTimer


#Llama Array
@onready var llamas: Array[PackedScene] = [
	preload("res://Nodes/Llamas/customer_1.tscn"),
	preload("res://Nodes/Llamas/customer_2.tscn"),
	preload("res://Nodes/Llamas/customer_3v2.tscn"),
	preload("res://Nodes/Llamas/customer_4.tscn"),
	preload("res://Nodes/Llamas/customer_5.tscn"),
	preload("res://Nodes/Llamas/customer_6.tscn"),
	preload("res://Nodes/Llamas/customer_7.tscn"),
	preload("res://Nodes/Llamas/customer_8.tscn"),
	preload("res://Nodes/Llamas/customer_9.tscn"),
	preload("res://Nodes/Llamas/customer_10.tscn"),
	preload("res://Nodes/Llamas/customer_11.tscn"),
	preload("res://Nodes/Llamas/customer_12.tscn"),
	preload("res://Nodes/Llamas/customer_13.tscn"),
	preload("res://Nodes/Llamas/customer_14.tscn"),
	preload("res://Nodes/Llamas/customer_15.tscn"),
	preload("res://Nodes/Llamas/customer_16.tscn"),
	preload("res://Nodes/Llamas/customer_17.tscn"),
	preload("res://Nodes/Llamas/customer_18.tscn"),
	preload("res://Nodes/Llamas/customer_19.tscn"),
	preload("res://Nodes/Llamas/customer_20.tscn"),
]
var customerProgress: int = 0
#var currentCustomer
var currentDialogue: DialogueData
var scores: Array[float]
var time_bonus: int = 5

#var toolEnables = {
#	0: false,
#	1: false,
#	2: false,
#	3: false
#}

var tutorials = {
	0: ["the basics", "Use WASD or arrow keys to move your razor and give these llamas the haircuts they desire!"],
	4: ["reference photos", "Some llamas like to bring in a reference photo for you to work off of. Try to match it as exactly as you can!"],
	9: ["tools", "You can press Q or E to switch tools. Try using some hair dye on your next customer!"],
	13: ["fur serum","Some llamas want less hair. Others want more. Use fur serum for the latter."],
	20: ["your hands","They're slippery. You feel the razor escaping your grip."]
}

var tutorialMode: bool

@export var llamaTalkSFX: Array[AudioStreamPlayer]

func _ready() -> void:
	$PlayerTool.active = false
	sequence_next()
	game_time_label.text = str(game_time_timer.time_left)
	game_time_timer.paused = true
	

func call_tutorial(header: String, body: String):
	$Sounds/GgaWoosh.play()
	tutorial_anim.play("Appear")
	header_label.text = header
	tutorial_label.text = body
	pass

func _connect_tuft_signals():
	if currentCustomer.tufts == null:
		print("Warning: currentCustomer.tufts is null!")
		return

	for t in currentCustomer.tufts:
		t.state_changed.connect(_on_tuft_state_changed)


func sequence_next():
	if !blockInput:
		seqCurrent += 1

	match seqCurrent:
		Sequence.START:
			# Check if a tutorial should play for this "progress step"
			if tutorials.has(customerProgress) and !tutorialOverride:
				call_tutorial(tutorials[customerProgress][0], tutorials[customerProgress][1])
				tutorialOverride = true
				seqCurrent -= 1
				return
			else:
				tutorialOverride = false
				# Are there still customers left?
				if customerProgress < llamas.size():
					# Pick a llama randomly that hasn't been used yet
					var available_indexes = []
					for i in range(llamas.size()):
						if i != currentCustomerIndex:
							available_indexes.append(i)
					var random_index = available_indexes.pick_random()
					currentCustomerIndex = random_index
					load_llama(llamas[random_index])
				else:
					await get_tree().create_timer(.75).timeout
					score_screen()
		Sequence.GAMEPLAY:
			start_gameplay()
		Sequence.SCORING:
			start_scoring()
		Sequence.SPIT:
			start_spit()
		Sequence.POST:
			start_post()
		Sequence.WRAP:
			seqCurrent = 0
			sequence_next()
func _on_tuft_state_changed():
	if currentCustomer == null:
		return
	if seqCurrent != Sequence.GAMEPLAY:
		return
	if is_finished():
		sequence_next()
		
#Load Llama Function
func load_llama(ll):
	# Remove previous llama if exists
	if currentCustomer != null:
		currentCustomer.queue_free()

	# Remove old reference if it exists
	if currentRef != null:
		currentRef.queue_free()

	# Instantiate new llama
	currentCustomer = ll.instantiate()
	$CustomerHolder.add_child(currentCustomer)

	# Wait one frame so _ready() runs and tufts exist
	await get_tree().process_frame

	# Connect tuft signals
	if currentCustomer.tufts != null:
		for t in currentCustomer.tufts:
			t.state_changed.connect(_on_tuft_state_changed)

	# Set up dialogue and sound references
	currentDialogue = currentCustomer.dialogue
	currentCustomer.ref = false
	currentCustomer.soundHolder = $Sounds

	# Play appear animation
	$CustomerHolder/CustomerAnimator.play("Appear")

	# Sound and footsteps
	$Sounds/Doorbell.play()
	footsteps()
	await get_tree().create_timer(1.0).timeout

	# Handle reference photo if required
	if not currentCustomer.showRef:
		$ReferenceHolder/ReferenceBackdrop.visible = false
		show_dialogue(currentDialogue.reqDialogue, currentDialogue.customerName)
		await get_tree().create_timer(3.0).timeout
		sequence_next()
	else:
		# Instantiate and show reference
		currentRef = ll.instantiate()
		$ReferenceHolder.add_child(currentRef)
		currentRef.ref = true
		currentRef.scale = Vector2(2, 2)

		# Start reference appear/disappear sequence
		ref_start()



func ref_start():
	ref_appear()
	await get_tree().create_timer(3).timeout
	ref_disappear()
	sequence_next()
	

func ref_appear():
	$Sounds/GgaWoosh.play()
	$ReferenceHolder/ReferenceBackdrop.visible = true
	$ReferenceHolder/ReferenceAnimator.play("Appear")
	$SpeechBubbleManager.create_bubble(Vector2(165,110), true, 0, currentDialogue.reqDialogue, 0, currentDialogue.customerName)
	pass

func ref_disappear():
	$Sounds/GgaWoosh.play()
	$ReferenceHolder/ReferenceAnimator.play("Disappear")
	$SpeechBubbleManager.remove_bubble()
	

func start_gameplay():
	$Sounds/GgaHaircutStart.play()
	$PlayerTool.active = true
	currentCustomer.toolEnabled = true
	var totalTime = 10
	if currentCustomer.timeOverride != 0:
		totalTime = currentCustomer.timeOverride
	add_time_to_timer(game_time_timer, currentCustomer.timeOverride)
	var tween = create_tween()
	tween.tween_property($GameTimeLabel/BonusTime, "visible", true, 0.01)
	tween.tween_interval(1.0)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 0.0, 1.5)
	tween.tween_property($GameTimeLabel/BonusTime, "visible", false, 0.01)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 1.0, 1.5)

	$PlayerTool/TimerLabel/Timer.wait_time = totalTime
	
	play_mid_dialogue(totalTime)
	#$SpeechBubbleManager.create_bubble(Vector2(-177,-78), false, 0, currentDialogue.midDialogue[0], totalTime - 1, currentDialogue.customerName)
	
	$PlayerTool/TimerLabel/Timer.start()
	
	$ToolHolder.show()
	
	if currentCustomer.disable_razor:
		$ToolHolder.disable_tool($ToolHolder/RazorIcon)
		toolEnables[0] = false
	else:
		$ToolHolder.enable_tool($ToolHolder/RazorIcon)
		toolEnables[0] = true
	
	if currentCustomer.disable_dye:
		$ToolHolder.disable_tool($ToolHolder/HairDyeIcon)
		$ToolHolder/HairDyeIcon/HairDyeIconColor.modulate = Color.WHITE
		toolEnables[1] = false
	else:
		$ToolHolder.enable_tool($ToolHolder/HairDyeIcon)
		$ToolHolder/HairDyeIcon/HairDyeIconColor.modulate = currentCustomer.dyeColor
		toolEnables[1] = true
	
	if currentCustomer.disable_rogaine:
		$ToolHolder.disable_tool($ToolHolder/RogaineIcon)
		toolEnables[2] = false
	else:
		$ToolHolder.enable_tool($ToolHolder/RogaineIcon)
		toolEnables[2] = true
	
	if currentCustomer.disable_fire_extinguisher:
		$ToolHolder.disable_tool($ToolHolder/FireExtinguisherIcon)
		toolEnables[3] = false
	else:
		$ToolHolder.enable_tool($ToolHolder/FireExtinguisherIcon)
		toolEnables[3] = true
	
	$ToolHolder.select_tool($ToolHolder/RazorIcon)
	pass


func play_mid_dialogue(totalTime):
	if currentDialogue.midDialogue.is_empty():
		return

	var count = currentDialogue.midDialogue.size()
	var segment_time = (totalTime - 1) / float(count)

	for s in range(count):
		llamaTalkSFX.pick_random().play()
		show_dialogue(currentDialogue.midDialogue[s], currentDialogue.customerName, segment_time)
		await get_tree().create_timer(segment_time).timeout

func show_dialogue(text: String, customerName: String, duration: float = 0) -> void:
	# Remove any existing speech bubble
	$SpeechBubbleManager.remove_bubble()
	
	# Only create if text is not empty
	if text != "":
		$SpeechBubbleManager.create_bubble(
			Vector2(-177, -78),
			false,
			0,
			text,
			duration,
			customerName
		)
func start_scoring():
	$Sounds/GgaHaircutEnd.play()
	add_time_to_timer(game_time_timer, time_bonus)
	var tween = create_tween()
	tween.tween_property($GameTimeLabel/BonusTime, "visible", true, 0.01)
	tween.tween_interval(1.0)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 0.0, 1.5)
	tween.tween_property($GameTimeLabel/BonusTime, "visible", false, 0.01)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 1.0, 1.5)
	$PlayerTool.active = false
	currentCustomer.toolEnabled = false
	#sound effect!
	
	$ToolHolder.hide()
	
	log_score()
	
	if find_score():
		$SpeechBubbleManager.create_bubble(Vector2(-177,-78), false, 0, currentDialogue.finshDialogueHappy, 2, currentDialogue.customerName)
	else:
		$SpeechBubbleManager.create_bubble(Vector2(-177,-78), false, 0, currentDialogue.finshDialogueUpset, 2, currentDialogue.customerName)
	
	$MirrorHolder/Mirror.play("Default")
	$MirrorHolder/MirrorAnim.play("Appear")
	await get_tree().create_timer(.5).timeout
	$MirrorHolder/Mirror.play("Turn")
	await get_tree().create_timer(.5).timeout
	
	if find_score():
		$MirrorHolder/Mirror.play("Sparkle")
		currentCustomer.animate_happy()
		$Sounds/GgaScorePositive.play()
	else:
		currentCustomer.animate_upset()
		$Sounds/GgaScoreNegative.play()
	
	await get_tree().create_timer(1).timeout
	$MirrorHolder/MirrorAnim.play("Disappear")
	$CustomerHolder/CustomerAnimator.play("Disappear")
	footsteps()
	await get_tree().create_timer(.75).timeout
	sequence_next()
		#llama's face updates
		#mirror animates off-screen
	#another short delay
		#score shows on-screen
		#score sound effect
		#score appearance updates to positive or negative
	#another short delay
		#llama sound effect
		#llama dialogue
	#another short delay
		#prompt player to progress
		#disable blockInput
	pass
	
func is_finished() -> bool:
	var tufts: Array = currentCustomer.tufts
	
	if tufts.size() == 0:
		return false
	
	for t in tufts:
		if t.currentState != t.desiredState:
			return false
	
	return true

func find_score() -> bool:
	var tufts: Array = currentCustomer.tufts
	var correct: float = 0
	var total: int = tufts.size()
	for t in tufts:
		if t.currentState == t.desiredState:
			correct += 1
	
	print("score: " + str(correct / total))
	if (correct / float(total)) >= currentCustomer.passingGradePercentage:
		return true
	else:
		return false

func log_score():
	var tufts: Array = currentCustomer.tufts
	var correct: float = 0
	var total: int = tufts.size()
	for t in tufts:
		if t.currentState == t.desiredState:
			correct += 1
	
	scores.append(correct / float(total))
	ScoreHolder.scores.append(correct / float(total))

func start_spit():
	sequence_next()
	pass

func footsteps():
	$"Sounds/GgaFootstep(1)".play()
	await get_tree().create_timer(.5).timeout
	$"Sounds/GgaFootstep(2)".play()
	await get_tree().create_timer(.5).timeout
	$"Sounds/GgaFootstep(3)".play()
	

func start_post():
	customerProgress += 1
	sequence_next()
	#enable blockInput
	#llama exit anim
	#spit total is shown
	#short delay
		#post-spit dialogue from off-screen
	#short delay
		#delete llama and clear currentCustomer
		#prompt player to progress
		#disable blockInput
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("Interact") and seqCurrent == Sequence.NONE and tutorialOverride:
		game_time_timer.paused = false
		sequence_next()
		tutorial_anim.play("Disappear")
		$"Sounds/GgaUiSelect(1)".play()
		pass
	# end the cut	
	if event.is_action_pressed("Interact") and seqCurrent == Sequence.GAMEPLAY:
		sequence_next()
	if event.is_action_pressed("Preview") and seqCurrent == Sequence.GAMEPLAY:
		#ref_appear()
		pass
	if event.is_action_released("Preview") and seqCurrent == Sequence.GAMEPLAY:
		#ref_disappear()
		pass

func _process(delta: float) -> void:
	game_time_label.text = str(int(game_time_timer.time_left))

	if seqCurrent == Sequence.GAMEPLAY and currentCustomer != null:
		if is_finished():
			sequence_next()
			
	if currentCustomer != null:
		if currentCustomer.murdered and !murdered:
			murdered = true
			print("murder 2")
			#$Sounds/AlpacaWtfWithSolo.stop()
			$Sounds/PopPunkTheme.stop()
			$"Sounds/GgaHairDye(2)".play()
			$CustomerHolder/BloodSplatter.play("Splatter")
			await get_tree().create_timer(.5).timeout
			print("murder 3")
			$Sounds/Whimper.play()
			await get_tree().create_timer(.5).timeout
			print("murder 4")
			score_screen()

func score_screen():
	print("Murder!")
	get_tree().change_scene_to_file("res://Scenes/score_screen.tscn")
	
func add_time_to_timer(timer: Timer, bonus: int) -> void:
	var new_time = timer.time_left + bonus
	timer.start(new_time)
	
func _on_timer_timeout():
	if seqCurrent == Sequence.GAMEPLAY:
		sequence_next()

func _on_game_time_timer_timeout():
	score_screen()

func _on_player_tool_tool_mode_changed(mode: Tool.Modes) -> void:
	toolMode = mode
	$Sounds/GgaSwap.play()
	if currentCustomer != null:
		currentCustomer.tool_mode = toolMode
