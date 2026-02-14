class_name Llama

extends Node2D

var toolEnabled: bool = false

var soundHolder

var ref: bool = false:
	set(value):
		ref = value
		if value:
			show_desired_tufts()

@export var showRef: bool = false
var tufts: Array[Tuft]
@export var skinColor: Color
@export var furColor: Color
@export var dyeColor: Color
@export var disable_razor: bool
@export var disable_rogaine: bool
@export var disable_fire_extinguisher: bool
@export var disable_dye: bool
@export var timeOverride: float
@export var dialogue: Resource
@export var passingGradePercentage: float

@export var bigEyesAlways: bool
@export var bigEyesWhenHappy: bool
@export var bigEyesWhenUpset: bool
@export var angryEyebrowsWhenUpset: bool

@export var happyNoises: Array[AudioStreamPlayer]
@export var upsetNoises: Array[AudioStreamPlayer]

@onready var gga_hair_dye_1_: AudioStreamPlayer = $"FurSFX/GgaHairDye(1)"
@onready var gga_rogaine_drop_: AudioStreamPlayer = $"FurSFX/GgaRogaine(drop)"

var murdered: bool:
	set(value):
		murdered = value
		for s in $LlamaSFX.get_children():
			s.stop()

var tool_mode: Tool.Modes

func _ready():
	color_llama()
	if bigEyesAlways:
		$LlamaRig/Eye.play("EyeBig")
	if tufts.size() == 0:
		for c in $Tufts.get_children():
			tufts.append(c)

func show_desired_tufts():
	for t in tufts:
		t.currentState = t.desiredState
		t.display()

func color_llama():
	if $LlamaRig != null:
		for c in $LlamaRig.get_children():
			if c.name != "Eye":
				c.modulate = skinColor

func _on_player_tool_tool_mode_changed(mode: Variant) -> void:
	tool_mode = mode
	print("tool mode change - signal received")


func animate_happy():
	var rng = randi_range(0,2)
	happyNoises[rng].play()
	$LlamaRig/Mouth.play("MouthHappy")
	$LlamaRig/Eyebrow.play("EyebrowHappy")
	if bigEyesWhenHappy:
		$LlamaRig/Eye.play("EyeBig")
	pass

func animate_upset():
	var rng = randi_range(0,2)
	upsetNoises[rng].play()
	$LlamaRig/Mouth.play("MouthUpset")
	if bigEyesWhenUpset:
		$LlamaRig/Eye.play("EyeBig")
	if angryEyebrowsWhenUpset:
		$LlamaRig/Eyebrow.play("EyebrowAngry")
	else:
		$LlamaRig/Eyebrow.play("EyebrowSad")
	pass
