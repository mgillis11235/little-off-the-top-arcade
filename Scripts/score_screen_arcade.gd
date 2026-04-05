extends Control

@onready var spit_earned = %SpitEarned
@onready var cust_seen = %CustSeen
@onready var perf_bonus = %PerfBonus
@onready var final_score = %FinalScore

#Announcer barks
var good_barks: Array[AudioStream] = []
var new_record_barks: Array[AudioStream] = []
var bad_barks: Array[AudioStream] = []

var final_score_value: int = 0

func _ready() -> void:
	$Play.grab_focus()
	
	load_barks("res://Audio/Vox/Score_Screen/Good/", good_barks)
	load_barks("res://Audio/Vox/Score_Screen/New_Record/", new_record_barks)
	load_barks("res://Audio/Vox/Score_Screen/Bad/", bad_barks)
	
	update_stats()
	hide_stats()
	
	$Play.grab_focus()

func update_stats() -> void:
	spit_earned.text = str(ScoreHolder.stats["final_spit"])
	cust_seen.text = str(ScoreHolder.stats["cust_seen"])
	perf_bonus.text = str(ScoreHolder.stats["perf_bonus"])
	final_score.text = str(final_score_value)
	
	final_score_value = ScoreHolder.stats["final_spit"] + \
						ScoreHolder.stats["cust_seen"] + \
						ScoreHolder.stats["perf_bonus"]
	
func hide_stats() -> void:
	for child in $VBoxContainer/HBoxContainer/VBoxContainer.get_children():
		child.self_modulate.a = 0.0
	for child in $VBoxContainer/HBoxContainer/VBoxContainer2.get_children():
		child.self_modulate.a = 0.0
	
	$VBoxContainer/HBoxContainer2/Label4.self_modulate.a = 0.0
	final_score.self_modulate.a = 0.0
	$Play.modulate.a = 0.0

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
	
	tween.tween_interval(1.0)
	tween.tween_property($Play, "position:y", 904, 0.3).from(get_viewport_rect().size.y)
	tween.parallel().tween_property($Play, "modulate:a", 1.0, 0.1).from(0.0)
	
	
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

	if score >= 150:
		play_random_from(new_record_barks)
	elif score >= 80:
		play_random_from(good_barks)
	else:
		play_random_from(bad_barks)
