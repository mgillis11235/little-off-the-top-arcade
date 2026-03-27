extends Control

@onready var spit_earned = %SpitEarned
@onready var cust_seen = %CustSeen
@onready var perf_bonus = %PerfBonus
@onready var final_score = %FinalScore


var final_score_value: int = 0

func _ready() -> void:
	update_stats()
	hide_stats()

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
		tween.tween_property(child, "position:x", 0.0, 0.25).from(-get_viewport_rect().size.x)
		tween.parallel().tween_property(child, "self_modulate:a", 1.0, 0.35).from(0.0)
		
	# animate stats values
	for i in range($VBoxContainer/HBoxContainer/VBoxContainer2.get_child_count()):
		var child = $VBoxContainer/HBoxContainer/VBoxContainer2.get_child(i)
		var key = ScoreHolder.stats.keys()[i]
		tween.tween_method(set_label_number.bind(child), 0, ScoreHolder.stats[key], 0.5)
		tween.parallel().tween_property(child, "self_modulate:a", 1.0, 0.05).from(0.0)
		tween.tween_interval(0.25)
	
	tween.tween_interval(0.25)
	
	# move final score label from left to right
	tween.tween_property($VBoxContainer/HBoxContainer2/Label4, "position:x", 0.0, 0.3).from(-get_viewport_rect().size.x)
	tween.parallel().tween_property($VBoxContainer/HBoxContainer2/Label4, "self_modulate:a", 1.0, 0.05).from(0.0)
	
	# final score count up
	tween.tween_method(set_label_number.bind(final_score), 0, final_score_value, 1.0)
	tween.parallel().tween_property(final_score, "self_modulate:a", 1.0, 0.05).from(0.0)
	
	tween.tween_interval(1.0)
	tween.tween_property($Play, "position:y", 904, 0.3).from(get_viewport_rect().size.y)
	tween.parallel().tween_property($Play, "modulate:a", 1.0, 0.1).from(0.0)

func set_label_number(number: int, label: Label) -> void:
	label.set_text(str(number))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
