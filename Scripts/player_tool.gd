extends CharacterBody2D
class_name Tool

@export var speed: float
@export var friction: float
@export var acceleration: float
@export var startingPoint: Vector2

@export var gm: BaseGameManager

enum Modes {RAZOR, DYE, ROGAINE, FIRE_EXTINGUISHER}
signal tool_mode_changed(mode: Modes)
signal tool_enabled_changed(onoff: bool)

var active: bool:
	set(value):
		active = value
		if value:
			visible = true
		else:
			visible = false
		position = startingPoint
		tool_mode = Modes.RAZOR
		tool_enabled_changed.emit(active)

var max_tools: int = 3
var tool_mode: Modes:
	set(value):
		print("Tool_Mode updated to " + str(value))
		var dir = value - tool_mode
		tool_mode = value
		if tool_mode > max_tools:
			tool_mode = 0
		elif tool_mode < 0:
			tool_mode = max_tools
		
		var allgood: bool = false
		
		if !gm.toolEnables[tool_mode]:
			if !allgood and gm.toolEnables.size() > tool_mode + dir and tool_mode + dir >= 0:
				if gm.toolEnables[tool_mode + dir]:
					tool_mode += dir
					allgood = true
			
			if !allgood and gm.toolEnables.size() > tool_mode + dir + dir and tool_mode + dir + dir >= 0:
				if gm.toolEnables[tool_mode + dir + dir]:
					tool_mode += dir + dir
					allgood = true
			
			if !allgood and gm.toolEnables.size() > tool_mode + dir + dir + dir and tool_mode + dir + dir >= 0:
				if gm.toolEnables[tool_mode + dir + dir + dir]:
					tool_mode += dir + dir + dir
					allgood = true
			
			if !allgood:
				tool_mode = 0
		
		print("tool mode changed - signal sent")
		tool_mode_changed.emit(tool_mode)

func increase_tool_mode(val: int):
	tool_mode += val

func _input(event: InputEvent):
	if active:
		if Input.is_action_just_pressed("ToolRight"):
			tool_mode += 1
		elif Input.is_action_just_pressed("ToolLeft"):
			tool_mode -= 1

func get_input():
	var input = Vector2()
	if Input.is_action_pressed("Right"):
		input.x += 1
	if Input.is_action_pressed("Left"):
		input.x -= 1
	if Input.is_action_pressed("Down"):
		input.y += 1
	if Input.is_action_pressed("Up"):
		input.y -= 1
	return input

func _physics_process(delta):
	if active:
		#z_index = -position.y + 500
		
		var direction = get_input()
		if direction.length() > 0:
			velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)
		move_and_slide()

func _process(delta: float):
	if active:
		var direction = get_input()
		if direction.length() > 0:
			var degrees: int = lerp(-20,20,(direction.x + 1)/2)
			rotation_degrees = lerp(int(rotation_degrees),degrees,acceleration)
		else:
			rotation_degrees = lerp(int(rotation_degrees),0,friction)
		
		if tool_mode == 0 and !$"../Sounds/RazorHum".playing:
			$"../Sounds/RazorHum".play()
		elif tool_mode != 0 and $"../Sounds/RazorHum".playing:
			$"../Sounds/RazorHum".stop()
		
		if tool_mode == 3 and !$"../Sounds/GgaExtinguisherLoop".playing:
			$"../Sounds/GgaExtinguisherLoop".play()
		elif tool_mode != 3 and $"../Sounds/GgaExtinguisherLoop".playing:
			$"../Sounds/GgaExtinguisherLoop".stop()
	else:
		if $"../Sounds/RazorHum".playing:
			$"../Sounds/RazorHum".stop()
		if $"../Sounds/GgaExtinguisherLoop".playing:
			$"../Sounds/GgaExtinguisherLoop".stop()
		

func disable_all_tools():
	$RazorAnim.visible = false
	$DyeAnim.visible = false
	$DyeAnim/DyeColorAnim.modulate = Color.WHITE
	$RogaineAnim.visible = false
	$FireExtAnim.visible = false
	$DefaultShape.disabled = false
	$FireExtShape.disabled = true
	pass

func _on_tool_mode_changed(mode: Tool.Modes):
	disable_all_tools()
	match mode:
		Modes.RAZOR:
			$RazorAnim.visible = true
			pass
		Modes.DYE:
			$DyeAnim.visible = true
			$DyeAnim/DyeColorAnim.modulate = gm.currentCustomer.dyeColor
			pass
		Modes.ROGAINE:
			$RogaineAnim.visible = true
			pass
		Modes.FIRE_EXTINGUISHER:
			$FireExtAnim.visible = true
			$DefaultShape.disabled = true
			$FireExtShape.disabled = false
			pass
	pass # Replace with function body.
