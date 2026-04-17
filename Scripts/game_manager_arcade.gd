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
var lastToolMode: Tool.Modes = Tool.Modes.RAZOR
var toolModeInitialized := false

# Multiplier for shaver speed (1 = normal)
var shaver_speed_multiplier: float = 1.0
var shaver_boost_timer: Timer

#Blink and red clock countdown variable
var clock_blink_timer: float = 0.0

# Difficulty scaling
var time_bonus_base: int = 5
var cash_base: float = 35.0
var perfect_bonus_base: int = 15

var difficulty_step: float = 0.05
var difficulty_min: float = 0.4 

#For whether you get cash or not
var skipped_customer: bool = false

signal sequence_update(seq: Sequence)

@onready var header_label: Label = $TutorialHolder/HeaderLabel
@onready var tutorial_label: Label = $TutorialHolder/TutorialLabel
@onready var tutorial_anim: AnimationPlayer = $TutorialHolder/TutorialAnim
@onready var game_time_label = $GameTimeLabel
@onready var game_time_timer = $GameTimeLabel/GameTimeTimer
@onready var cash_label: Label = $TillHolder/CashLabel

#Theme music
@onready var pop_punk_theme = $Sounds/PopPunkTheme
@onready var pop_punk_theme_2 = $Sounds/PopPunkTheme2


#Grab clipper/announcer barks
var bark_sounds: Array[AudioStream] = []
var clipper_sounds: Array[AudioStream] = []
var nitro_bark_sounds: Array[AudioStream] = []

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
	preload("res://Nodes/Llamas/customer_22.tscn"),
	preload("res://Nodes/Llamas/customer_23.tscn"),
	preload("res://Nodes/Llamas/customer_24.tscn"),
	preload("res://Nodes/Llamas/customer_25.tscn"),
	preload("res://Nodes/Llamas/customer_26.tscn"),
	preload("res://Nodes/Llamas/customer_27.tscn"),
	preload("res://Nodes/Llamas/customer_28.tscn"),
	preload("res://Nodes/Llamas/customer_29.tscn"),
	preload("res://Nodes/Llamas/customer_30.tscn"),
	preload("res://Nodes/Llamas/customer_31.tscn"),
	preload("res://Nodes/Llamas/customer_32.tscn"),
]
var customerProgress: int = 0
#var currentCustomer
var currentDialogue: DialogueData
var scores: Array[float]
var time_bonus: int = 5
var llamaQueue: Array[int] = []
var cash = 0

#var toolEnables = {
#	0: false,
#	1: false,
#	2: false,
#	3: false
#}

var tutorials = {
	0: ["how to play", "Make the llamas look like their reference pics before time runs out!
	
		Move your tools - razor, rogaine, hair dye, or extinguisher - with WASD, and swap them with Q/E.
		
		End a cut early with SPACE.
		
		Tip: Better cuts earn more $pit."],
	#4: ["reference photos", "Some llamas like to bring in a reference photo for you to work off of. Try to match it as exactly as you can!"],
	#9: ["tools", "You can press Q or E to switch tools. Try using some hair dye on your next customer!"],
	#13: ["fur serum","Some llamas want less hair. Others want more. Use fur serum for the latter."],
	#20: ["your hands","They're slippery. You feel the razor escaping your grip."]
}

var tutorialMode: bool

@export var llamaTalkSFX: Array[AudioStreamPlayer]
@export var perfection_bonus: int = 20
@export var perfect_time_bonus: int = 5

func _ready() -> void:
	clear_scores()
	
	pop_punk_theme.finished.connect(func(): pop_punk_theme_2.play())
	pop_punk_theme_2.finished.connect(func(): pop_punk_theme.play())
	
	$PlayerTool.active = false
	
	# Create shuffled llama order
	llamaQueue.clear()
	for i in range(llamas.size()):
		llamaQueue.append(i)
	llamaQueue.shuffle()
	
	sequence_next()
	game_time_label.text = str(game_time_timer.time_left)
	game_time_timer.paused = true
	
	#Bonus
	shaver_boost_timer = Timer.new()
	add_child(shaver_boost_timer)
	shaver_boost_timer.one_shot = true
	shaver_boost_timer.timeout.connect(_on_shaver_boost_timeout)
	
	load_bark_sounds()
	load_clipper_sounds()
	load_nitro_bark_sounds()

#Difficulty scaling
func get_difficulty_multiplier() -> float:
	var mult = 1.4 - (customerProgress * difficulty_step) #difficulty multiplier 
	return max(mult, difficulty_min)

func load_bark_sounds():
	var dir = DirAccess.open("res://Audio/Vox/")
	if dir == null:
		push_error("Could not open Vox directory.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".ogg"):
			var path = "res://Audio/Vox/" + file_name
			var sound = load(path)
			if sound != null:
				bark_sounds.append(sound)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
func play_random_bark():
	if bark_sounds.is_empty():
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = bark_sounds.pick_random()
	player.finished.connect(player.queue_free)
	player.play()

func load_clipper_sounds():
	var dir = DirAccess.open("res://Audio/Vox/Clipper/")
	if dir == null:
		push_error("Could not open Clipper directory.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".ogg"):
			var path = "res://Audio/Vox/Clipper/" + file_name
			var sound = load(path)
			if sound != null:
				clipper_sounds.append(sound)
		file_name = dir.get_next()
	
	dir.list_dir_end()

func load_nitro_bark_sounds():
	var dir = DirAccess.open("res://Audio/Vox/Nitro/")
	if dir == null:
		push_error("Could not open Nitro directory.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".ogg"):
			var path = "res://Audio/Vox/Nitro/" + file_name
			var sound = load(path)
			if sound != null:
				nitro_bark_sounds.append(sound)
		file_name = dir.get_next()
	
	dir.list_dir_end()

func play_random_nitro_bark():
	if nitro_bark_sounds.is_empty():
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = nitro_bark_sounds.pick_random()
	player.finished.connect(player.queue_free)
	player.play()

#Speed boost bonus handling for perfect scores
func _on_shaver_boost_timeout():
	shaver_speed_multiplier = 1.0
	$PlayerTool/SpeedParticles.emitting = false
	
func play_random_clipper_sound():
	if clipper_sounds.is_empty():
		return
	
	$ClipperBarkPlayer.stream = clipper_sounds.pick_random()
	$ClipperBarkPlayer.pitch_scale = randf_range(0.95, 1.05) # subtle variation
	$ClipperBarkPlayer.play()

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
			# Tutorial check
			if tutorials.has(customerProgress) and !tutorialOverride:
				call_tutorial(tutorials[customerProgress][0], tutorials[customerProgress][1])
				tutorialOverride = true
				seqCurrent -= 1
				return
			else:
				tutorialOverride = false

			# Refill shuffled queue if empty
			if llamaQueue.is_empty():
				var last = currentCustomerIndex
				
				for i in range(llamas.size()):
					llamaQueue.append(i)
				
				llamaQueue.shuffle()
				
				# Prevent immediate repeat across reshuffle
				if llamaQueue.size() > 1 and llamaQueue[0] == last:
					var temp = llamaQueue[0]
					llamaQueue[0] = llamaQueue[1]
					llamaQueue[1] = temp

			# Pull next llama
			var next_index = llamaQueue.pop_front()
			currentCustomerIndex = next_index
			
			load_llama(llamas[next_index])
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
		
func load_llama(ll):
	
	#Resets for skipping customer no cash penalty
	skipped_customer = false
	
	# Add to the number of customers seen
	ScoreHolder.stats["cust_seen"] += 1
	# Stop any dialogue still running
	$SpeechBubbleManager.stop_dialogue()

	# Remove previous llama
	if currentCustomer != null:
		currentCustomer.queue_free()

	# Remove old reference
	if currentRef != null:
		currentRef.queue_free()

	currentCustomer = ll.instantiate()
	$CustomerHolder.add_child(currentCustomer)
	await get_tree().process_frame
	
	# show reference photo always, even if showRef is 'false' in the resource
	if currentCustomer.showRef == false:
		currentCustomer.showRef = true

	# Connect tufts
	if currentCustomer.tufts != null:
		for t in currentCustomer.tufts:
			t.state_changed.connect(_on_tuft_state_changed)

	currentDialogue = currentCustomer.dialogue
	currentCustomer.ref = false
	currentCustomer.soundHolder = $Sounds

	$CustomerHolder/CustomerAnimator.play("Appear")
	$Sounds/Doorbell.play()
	footsteps()
	await get_tree().create_timer(1.0).timeout

	# Start shaver boost timer if multiplier > 1
	if shaver_speed_multiplier > 1.0:
		shaver_boost_timer.wait_time = 10.0  # boost lasts the whole next llama gameplay
		shaver_boost_timer.start()

	if not currentCustomer.showRef:
		$ReferenceHolder/ReferenceBackdrop.visible = false

		#$SpeechBubbleManager.play_dialogue(
			#currentDialogue.reqDialogue,
			#currentDialogue.customerName,
			#3.0
		#)

		await get_tree().create_timer(3.0).timeout
		sequence_next()

	else:
		currentRef = ll.instantiate()
		$ReferenceHolder.add_child(currentRef)
		currentRef.ref = true
		currentRef.scale = Vector2(2,2)

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
	#$SpeechBubbleManager.play_dialogue(
		#currentDialogue.reqDialogue,
		#currentDialogue.customerName,
		#3
	#)
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
	
	#$SpeechBubbleManager.play_dialogue(
		#currentDialogue.midDialogue,
		#currentDialogue.customerName,
		#totalTime - 1
#)
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
	$SpeechBubbleManager.stop_dialogue()
	$Sounds/GgaHaircutEnd.play()
	var scaled_time_bonus = int(time_bonus_base * get_difficulty_multiplier())
	add_time_to_timer(game_time_timer, scaled_time_bonus)
	
	var tween = create_tween()
	tween.tween_property($GameTimeLabel/BonusTime, "visible", true, 0.01)
	tween.tween_interval(1.0)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 0.0, 1.5)
	tween.tween_property($GameTimeLabel/BonusTime, "visible", false, 0.01)
	tween.tween_property($GameTimeLabel/BonusTime, "modulate:a", 1.0, 1.5)
	
	$PlayerTool.active = false
	currentCustomer.toolEnabled = false
	$ToolHolder.hide()
	
	var perfect := false
	if find_score():
		perfect = currentCustomer.tufts.size() > 0 and currentCustomer.tufts.filter(func(t): return t.currentState != t.desiredState).size() == 0
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
		if perfect:
			# Only play Perfect sound, no bark
			play_random_nitro_bark()
			# Add to perfection score bonus
			ScoreHolder.stats["perf_bonus"] += perfection_bonus
			add_time_to_timer(game_time_timer, perfect_time_bonus)
		else:
			$Sounds/GgaScorePositive.play()
			play_random_bark()
	else:
		currentCustomer.animate_upset()
		$Sounds/GgaScoreNegative.play()
		play_random_bark()
	
	await get_tree().create_timer(1).timeout
	$MirrorHolder/MirrorAnim.play("Disappear")
	$CustomerHolder/CustomerAnimator.play("Disappear")
	log_score()
	footsteps()
	await get_tree().create_timer(.75).timeout
	sequence_next()
	
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
	
	var ratio := 0.0
	if total > 0:
		ratio = correct / float(total)
	
	# Store score
	scores.append(ratio)
	ScoreHolder.scores.append(ratio)

	# Calculate earned cash, but only if we haven't skipped the customer
	var earned := 0.0

	if not skipped_customer:
		earned = cash_base * get_difficulty_multiplier() * ratio

	if earned > 0:
		# Play money/spit sound and popup only if earned > 0
		$Sounds/Money.play()
		$Sounds/Spit.play()
		await get_tree().create_timer(0.25).timeout
		cash += round(earned)
		spawn_cash_popup(earned, ratio == 1.0) # gold popup if perfect
		update_cash_display()

	# Perfect bonus handling
	if ratio == 1.0:
		cash += 15
		update_cash_display()
		
		# Activate shaver speed boost for next llama
		shaver_speed_multiplier = 1.6
		shaver_boost_timer.stop()  # stop any previous timer, just in case
		$PlayerTool/SpeedParticles.emitting = true
		# The timer wait time will be set when the next llama loads
	else:
		pass
		# Play random llama bark if not perfect
		#play_random_bark()
	
	print("Earned: ", earned, " | Total cash: ", cash)
	
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
	if event.is_action_pressed("ScoreScreen"):
		score_screen()
	if event.is_action_pressed("ui_accept") and seqCurrent == Sequence.NONE and tutorialOverride:
		game_time_timer.paused = false
		sequence_next()
		tutorial_anim.play("Disappear")
		$"Sounds/GgaUiSelect(1)".play()
		pass
	# end the cut	
	if event.is_action_pressed("Interact") and seqCurrent == Sequence.GAMEPLAY:
		skipped_customer = true
		sequence_next()
	if event.is_action_pressed("Preview") and seqCurrent == Sequence.GAMEPLAY:
		#ref_appear()
		pass
	if event.is_action_released("Preview") and seqCurrent == Sequence.GAMEPLAY:
		#ref_disappear()
		pass

func _process(delta: float) -> void:
	game_time_label.text = str(int(game_time_timer.time_left))

	# Flash red + blink when 10 seconds or less
	if game_time_timer.time_left <= 10 and not game_time_timer.paused:
		clock_blink_timer += delta * 6.0  # speed of blinking

		var blink := sin(clock_blink_timer) > 0

		if blink:
			game_time_label.modulate = Color(1, 0.2, 0.2) # red
			$Sounds/Timer.play()
		else:
			game_time_label.modulate = Color(1, 1, 1) # white

	else:
		# Reset when above 10 seconds
		game_time_label.modulate = Color(1, 1, 1)
		clock_blink_timer = 0.0
		$Sounds/Timer.stop()
		
	if seqCurrent == Sequence.GAMEPLAY and currentCustomer != null:
		if is_finished() and not currentCustomer.is_in_group("no_auto_finish"):
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
	ScoreHolder.stats["final_spit"] = cash
	get_tree().change_scene_to_file("res://Scenes/score_screen_arcade.tscn")
	play_random_bark()
	
func add_time_to_timer(timer: Timer, bonus: int) -> void:
	var new_time = timer.time_left + bonus
	timer.start(new_time)
	
func _on_timer_timeout():
	if seqCurrent == Sequence.GAMEPLAY:
		sequence_next()
		
func _on_game_time_timer_timeout():
	score_screen()
	
func update_cash_display():
	cash_label.text = "$pit:   " + str(int(cash))

	# Remove existing tween so they don't stack weirdly
	if cash_label.has_meta("tween"):
		var old_tween = cash_label.get_meta("tween")
		if old_tween:
			old_tween.kill()

	var tween = create_tween()
	cash_label.set_meta("tween", tween)

	# Store original color
	var original_color: Color = cash_label.modulate
	var money_green := Color(0.4, 1.0, 0.4)

	tween.tween_property(
		cash_label, "scale",
		Vector2(1.35, 1.35),
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	#Color to green
	tween.parallel().tween_property(
		cash_label, "modulate",
		money_green,
		0.25
	)

	tween.tween_interval(0.1)

	tween.tween_property(
		cash_label, "scale",
		Vector2(1, 1),
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		cash_label, "modulate",
		original_color,
		0.45
	)

func spawn_cash_popup(amount: float, perfect: bool = false) -> void:
	if amount <= 0:
		return # don't spawn anything if the player earned nothing

	var popup = Label.new()
	add_child(popup)

	# Text
	popup.text = "+$" + str(int(amount))
	popup.position = cash_label.global_position + Vector2(0, -10)

	# Style
	if perfect:
		popup.modulate = Color(1.0, 0.84, 0.0) # gold for perfect
	else:
		popup.modulate = Color(0.4, 1.0, 0.4) # green for normal
	popup.scale = Vector2(1, 1)

	# Optional particles for perfect
	if perfect:
		var particles = CPUParticles2D.new()
		particles.amount = 20
		particles.lifetime = 0.6
		particles.one_shot = true
		particles.position = popup.position
		particles.direction = Vector2(0, -1)
		particles.speed_scale = 150
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
		particles.gravity = Vector2(0, 300)
		particles.color = Color(1.0, 0.84, 0.0)
		add_child(particles)
		particles.emitting = true
		await get_tree().create_timer(particles.lifetime).timeout
		particles.queue_free()

	# Animate popup
	var tween = create_tween()

	# Move upward
	tween.tween_property(
		popup, "position",
		popup.position + Vector2(0, -50),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Fade out
	tween.parallel().tween_property(
		popup, "modulate:a",
		0.0,
		1.0
	)

	# Slight scale up (juicy)
	tween.parallel().tween_property(
		popup, "scale",
		Vector2(1.3, 1.3),
		0.4
	)

	# Cleanup
	tween.finished.connect(popup.queue_free)
	
func clear_scores() -> void:
	ScoreHolder.stats["cust_seen"] = 0
	ScoreHolder.stats["final_spit"] = 0
	ScoreHolder.stats["perf_bonus"] = 0 
	
func _on_player_tool_tool_mode_changed(mode: Tool.Modes) -> void:
	toolMode = mode
	
	# Always update customer tool mode
	if currentCustomer != null:
		currentCustomer.tool_mode = toolMode
	
	# Prevent sound outside gameplay
	if seqCurrent != Sequence.GAMEPLAY:
		lastToolMode = mode
		return
	
	# Prevent sound on first initialization
	if not toolModeInitialized:
		lastToolMode = mode
		toolModeInitialized = true
		return
	
	# Prevent sound if same tool
	if mode == lastToolMode:
		return
	
	lastToolMode = mode
	
	$Sounds/GgaSwap.play()
	play_random_clipper_sound()
	
	# Only turn on when the razor is active
	if mode == Tool.Modes.RAZOR:
		$PlayerTool/SpeedParticles.emitting = true
	else:
		$PlayerTool/SpeedParticles.emitting = false
