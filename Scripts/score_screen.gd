extends Node

@onready var score_letter: Label = $ScoreLetter
@onready var score_caption: Label = $ScoreCaption

var scores = {
	
	0: ["S","LLAMAZING! Your tonsorial talent can't be beat.", Color.YELLOW],
	1: ["A","LLUSTRIOUS! You lleft it all out on the salon floor.", Color.WHITE],
	2: ["B","LLOVELY! You've lleft your llamas delighted.", Color.WHITE],
	3: ["C","UNLLUCKY. You can do better than this!", Color.WHITE],
	4: ["D","PRETTY LLAME. Better luck next time.", Color.BLUE],
	5: ["F","LLOSER! Go back to barber schooll!", Color.RED]
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ScoreHolder.scores.size() > 0:
		var avg: float
		for s in ScoreHolder.scores:
			avg += s
		avg = avg / ScoreHolder.scores.size()
		
		print(avg)
		
		var scoreIndex = 0
		
		if avg >= .95:
			scoreIndex = 0
			$BarberBitFix.play()
		elif avg >= .85:
			scoreIndex = 1
			$BarberBitFix.play()
		elif avg >= .75:
			scoreIndex = 2
			$BarberBitFix.play()
		elif avg >= .6:
			scoreIndex = 3
		elif avg >= .4:
			scoreIndex = 4
		else:
			scoreIndex = 5
		
		score_letter.text = scores[scoreIndex][0]
		score_letter.modulate = scores[scoreIndex][2]
		score_caption.text = scores[scoreIndex][1]
	pass # Replace with function body.


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
	pass # Replace with function body.
