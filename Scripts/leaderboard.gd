extends VBoxContainer
class_name Leaderboard

@export var leaderboard_id := "REPLACE_WITH_YOUR_LEADERBOARD_ID"
@export var api_key := "REPLACE_WITH_YOUR_API_KEY"
@export var entries_container: VBoxContainer

@onready var simpleboards = $SimpleBoardsApi
@onready var leaderboard_font = preload("res://Fonts/Schoolbell-Regular.ttf")

var header_font_size : int = 40
var entry_font_size : int = 30
var separation : int = 60

func _ready():
	simpleboards.set_api_key(api_key)
	simpleboards.entries_got.connect(_on_entries_got)
	simpleboards.request_failed.connect(_on_request_failed)

	get_scores()



func get_scores() -> void:
	await simpleboards.get_entries(leaderboard_id)


func _on_entries_got(entries) -> void:
	_clear_entries()
	_add_header_row()

	if entries == null or entries.size() == 0:
		_show_empty_state()
		return
	
	if entries.size() > 8:
		ScoreHolder.lowest_high_score = entries[9]
		ScoreHolder.not_enough_scores_yet = false

	for i in entries.size():
		var entry = entries[i]
		entries_container.add_child(_create_entry_row(entry))


func _on_request_failed(response_code, body) -> void:
	_clear_entries()

	var label := Label.new()
	label.text = "Failed to load leaderboard"
	entries_container.add_child(label)

	push_warning("SimpleBoards request failed: %s - %s" % [response_code, body])


func _clear_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()


func _show_empty_state() -> void:
	var label := Label.new()
	label.text = "No entries yet, be the first!"
	entries_container.add_child(label)


func _create_entry_row(entry) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", separation)

	var name_label := Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", leaderboard_font)
	name_label.add_theme_font_size_override("font_size", entry_font_size)
	name_label.text = str(entry.playerDisplayName)
	#name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL # might have to tweak this value since it's a holdover from when there were 4 labels (rank, name, score, time)

	var score_label := Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_override("font", leaderboard_font)
	score_label.add_theme_font_size_override("font_size", entry_font_size)
	score_label.text = str(entry.score)
	score_label.custom_minimum_size.x = 80 # might have to tweak this value since it's a holdover from when there were 4 labels (rank, name, score, time)

	row.add_child(name_label)
	row.add_child(score_label)

	return row


func _format_metadata(entry) -> String:
	if entry == null:
		return ""

	if "metadata" not in entry:
		return ""

	return str(entry.metadata)

func _add_header_row() -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", separation)

	var name_label := Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", leaderboard_font)
	name_label.add_theme_color_override("font_color", Color.ANTIQUE_WHITE)
	name_label.add_theme_font_size_override("font_size", header_font_size)
	name_label.text = "Name"
	#name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL # might have to tweak this value since it's a holdover from when there were 4 labels (rank, name, score, time)

	var score_label := Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_override("font", leaderboard_font)
	score_label.add_theme_color_override("font_color", Color.ANTIQUE_WHITE)
	score_label.add_theme_font_size_override("font_size", header_font_size)
	score_label.text = "Score"
	#score_label.custom_minimum_size.x = 80 # might have to tweak this value since it's a holdover from when there were 4 labels (rank, name, score, time)

	row.add_child(name_label)
	row.add_child(score_label)

	entries_container.add_child(row)
