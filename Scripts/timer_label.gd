extends Node

var currentSeq: int:
	set(value):
		currentSeq = value
		if value != 2:
			self.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentSeq == 2:
		var time_left = ceil($Timer.time_left)
		self.text = str(time_left)
	pass


func _on_game_sequence_update(seq: int):
	currentSeq = seq
