extends Control

@export var leaderboard_id := "REPLACE_WITH_YOUR_LEADERBOARD_ID"
@export var api_key := "REPLACE_WITH_YOUR_API_KEY"

@export var player_name: LineEdit
@export var submit_button: Button
@export var leaderboard: Leaderboard

@onready var simpleboards := $SimpleBoardsApi

@onready var spit_earned = %SpitEarned
@onready var cust_seen = %CustSeen
@onready var perf_bonus = %PerfBonus
@onready var final_score = %FinalScore

#Announcer barks
var good_barks: Array[AudioStream] = []
var new_record_barks: Array[AudioStream] = []
var bad_barks: Array[AudioStream] = []

var final_score_value: int = 0
var new_high_score := false

var _time_text := ""
var _is_sending := false
var _is_sent := false

func _ready() -> void:
	
	simpleboards.set_api_key(api_key)
	simpleboards.entry_sent.connect(_on_entry_sent)
	simpleboards.request_failed.connect(_on_request_failed)
	
	player_name.text_changed.connect(_on_text_changed)
	submit_button.pressed.connect(_on_submit_score_button_pressed)
	
	$ReturnToTitle.grab_focus()
	
	load_barks("res://Audio/Vox/Score_Screen/Good/", good_barks)
	load_barks("res://Audio/Vox/Score_Screen/New_Record/", new_record_barks)
	load_barks("res://Audio/Vox/Score_Screen/Bad/", bad_barks)
	
	update_stats()
	hide_stats()
	
	check_if_new_high_score()
	
	$ReturnToTitle.grab_focus()

func check_if_new_high_score() -> void:
	if ScoreHolder.lowest_high_score < final_score_value or ScoreHolder.not_enough_scores_yet:
		new_high_score = true

func update_stats() -> void:
	spit_earned.text = str(ScoreHolder.stats["final_spit"])
	cust_seen.text = str(ScoreHolder.stats["cust_seen"])
	perf_bonus.text = str(ScoreHolder.stats["perf_bonus"])
	final_score.text = str(final_score_value)
	
	final_score_value = ScoreHolder.stats["final_spit"] + \
						ScoreHolder.stats["cust_seen"] + \
						ScoreHolder.stats["perf_bonus"]
	
	# check if there's a new high score, and if so, set new_high_score to 'true'
	
func hide_stats() -> void:
	for child in $VBoxContainer/HBoxContainer/VBoxContainer.get_children():
		child.self_modulate.a = 0.0
	for child in $VBoxContainer/HBoxContainer/VBoxContainer2.get_children():
		child.self_modulate.a = 0.0
	
	$VBoxContainer/HBoxContainer2/Label4.self_modulate.a = 0.0
	final_score.self_modulate.a = 0.0
	$ReturnToTitle.modulate.a = 0.0

func animate_stats() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# move labels in from left to right
	for child in $VBoxContainer/HBoxContainer/VBoxContainer.get_children():
		tween.tween_callback(func(): $Whoosh.play())
		tween.tween_property(child, "position:x", 0.0, 0.25).from(-get_viewport_rect().size.x)
		tween.parallel().tween_property(child, "self_modulate:a", 1.0, 0.35).from(0.0)	
	
	# animate stats values
	for i in range($VBoxContainer/HBoxContainer/VBoxContainer2.get_child_count()):
		var child = $VBoxContainer/HBoxContainer/VBoxContainer2.get_child(i)
		var key = ScoreHolder.stats.keys()[i]

		tween.tween_callback(func(): $Slam.play())
		tween.tween_method(set_label_number.bind(child), 0, ScoreHolder.stats[key], 0.5)
		tween.parallel().tween_property(child, "self_modulate:a", 1.0, 0.05).from(0.0)

		tween.tween_interval(0.25)
	
	tween.tween_interval(0.25)
	
	# move final score label from left to right
	tween.tween_callback(func(): $Whoosh.play())
	tween.tween_callback(func(): $Slam.play())
	tween.tween_property($VBoxContainer/HBoxContainer2/Label4, "position:x", 0.0, 0.3).from(-get_viewport_rect().size.x)
	tween.parallel().tween_property($VBoxContainer/HBoxContainer2/Label4, "self_modulate:a", 1.0, 0.05).from(0.0)
	# final score count up
	tween.tween_method(set_label_number.bind(final_score), 0, final_score_value, 1.0)
	tween.parallel().tween_property(final_score, "self_modulate:a", 1.0, 0.05).from(0.0)
	
	tween.tween_callback(play_score_bark)
	
	if not new_high_score:
		tween.tween_interval(1.0)
		tween.tween_property($ReturnToTitle, "position:y", 904, 0.3).from(get_viewport_rect().size.y)
		tween.parallel().tween_property($ReturnToTitle, "modulate:a", 1.0, 0.1).from(0.0)
	else:
		await tween.finished
		$HighScorePanel.visible = true
	
	
func set_label_number(number: int, label: Label) -> void:
	label.set_text(str(number))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

func load_barks(path: String, target_array: Array):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Could not open: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".ogg"):
			var sound = load(path + file_name)
			if sound:
				target_array.append(sound)
		file_name = dir.get_next()
	
	dir.list_dir_end()

func play_random_from(arr: Array):
	if arr.is_empty():
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = arr.pick_random()
	player.finished.connect(player.queue_free)
	player.play()
	
func play_score_bark():
	var score = final_score_value

	if new_high_score:
		play_random_from(new_record_barks)
	elif score >= 80:
		play_random_from(good_barks)
	else:
		play_random_from(bad_barks)
	

func _on_text_changed(new_text: String):
	player_name.text = new_text.to_upper()
	player_name.caret_column = player_name.text.length()

func _on_submit_score_button_pressed() -> void:
	if _is_sending or _is_sent:
		return

	_is_sending = true
	_update_submit_ui()

	@warning_ignore("shadowed_variable_base_class")
	var name := player_name.text.strip_edges()
	if name.is_empty():
		name = "???"

	await simpleboards.send_score_without_id(
		leaderboard_id,
		name,
		str(final_score_value),
		_time_text
	)

func _on_entry_sent(_entry) -> void:
	_is_sending = false
	_is_sent = true
	_update_submit_ui()
	leaderboard.get_scores()

func _on_request_failed(_response_code, _body) -> void:
	_is_sending = false
	_is_sent = false
	_update_submit_ui()
	
func _update_submit_ui() -> void:
	if _is_sending:
		submit_button.disabled = true
		submit_button.text = "Submitting..."
		player_name.editable = false
		return

	if _is_sent:
		submit_button.disabled = true
		submit_button.text = "Score saved"
		player_name.editable = false
		
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($ReturnToTitle, "position:y", 904, 0.3).from(get_viewport_rect().size.y)
		tween.parallel().tween_property($ReturnToTitle, "modulate:a", 1.0, 0.1).from(0.0)
		return

	submit_button.disabled = false
	submit_button.text = "Submit Score"
	player_name.editable = true
