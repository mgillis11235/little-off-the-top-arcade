class_name Tuft

extends Area2D

enum States { NORMAL, SHAVED, FIRE, DYED, CHARRED }

signal state_changed

@export var startState: States
@export var currentState: States
@export var desiredState: States
@export var noStubble: bool
@export var murderTuft: bool

@export var llama: Node2D = null


@onready var furNormal: AnimatedSprite2D = $FurNormal
@onready var stubble: AnimatedSprite2D = $Stubble
@onready var fire: AnimatedSprite2D = $Fire

#@onready var currentTuft: AnimatedSprite2D = $FurNormal


var shorn: bool = false


var tool_state: int = 0

func _ready():
	currentState = startState
	z_sort()
	display()

func randomize_fur():
	
	var tuftRandom: int = randi_range(0, 11)
	$FurNormal.play("FurIdle" + str(tuftRandom))
	
	var stubbleRandom: int = randi_range(0, 2)
	stubble.play("Stubble" + str(stubbleRandom))
	
	var fireRandom: int = randi_range(0, 2)
	$Fire.play("FireIdle" + str(fireRandom))
	

func z_sort():
	z_index = -position.y + 500

func display():
	modulate = Color.WHITE
	furNormal.visible = false
	fire.visible = false
	
	match currentState:
		States.NORMAL:
			furNormal.visible = true
			stubble.visible = false
			fire.visible = false
			furNormal.modulate = llama.furColor
		States.SHAVED:
			furNormal.visible = false
			if noStubble:
				stubble.visible = false
			else:
				stubble.visible = true
			fire.visible = false
		States.FIRE:
			furNormal.visible = false
			stubble.visible = false
			fire.visible = true
		States.DYED:
			furNormal.visible = true
			stubble.visible = false
			fire.visible = false
			furNormal.modulate = llama.dyeColor
		States.CHARRED:
			furNormal.visible = false
			stubble.visible = false
			fire.visible = false
	
	randomize_fur()


func shave():
	if currentState == States.NORMAL or currentState == States.DYED:
		$FurShaveParticles.process_material.color = llama.furColor
		$FurShaveParticles.emitting = true
		currentState = States.SHAVED
		llama.soundHolder.get_node("GgaRazorRev(2)").play()
		llama.soundHolder.get_node("GgaWoosh2").play()
		display()
		emit_signal("state_changed")
		
func regrow():
	if currentState == States.SHAVED:
		currentState = States.NORMAL
		llama.gga_rogaine_drop_.play()
		display()
		emit_signal("state_changed")

func dye():
	if currentState == States.NORMAL:
		currentState = States.DYED
		llama.gga_hair_dye_1_.play()
		display()
		emit_signal("state_changed")

func douse():
	if currentState == States.FIRE:
		currentState = States.CHARRED
		llama.soundHolder.get_node("GgaDouse(2)").play()
		$FireParticles.process_material.color = Color.BLACK
		$FireParticles.process_material.color.a = .5
		$FireParticles.emitting = true
		display()
		emit_signal("state_changed")

func _on_body_entered(body: Node2D):
	
	if llama.ref == false and llama.toolEnabled:
		match llama.tool_mode:
			Tool.Modes.RAZOR:
				shave()
				if murderTuft:
					llama.murdered = true
					print("murder 1")
			Tool.Modes.ROGAINE:
				regrow()
			Tool.Modes.DYE:
				dye()
			Tool.Modes.FIRE_EXTINGUISHER:
				douse()
