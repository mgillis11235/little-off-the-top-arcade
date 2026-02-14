extends Node

@export var disableColor: Color
@export var enableColor: Color
@export var allTools: Array[AnimatedSprite2D]

func hide():
	$ToolHolderAnim.play("Disappear")
	$Indicator.visible = false
	pass

func show():
	$ToolHolderAnim.play("Appear")
	pass

func disable_tool(tool: AnimatedSprite2D):
	tool.modulate = disableColor
	pass

func enable_tool(tool: AnimatedSprite2D):
	tool.modulate = enableColor
	tool.visible = true
	pass

func select_tool(tool: AnimatedSprite2D):
	for t in allTools:
		if t.modulate != disableColor:
			t.modulate = enableColor
		t.play("Inactive")
	tool.play("Active")
	tool.modulate = Color.WHITE
	$Indicator.visible = true
	$Indicator.position.x = tool.position.x
	pass


func _on_player_tool_tool_mode_changed(mode: Tool.Modes):
	match mode:
		Tool.Modes.RAZOR:
			select_tool($RazorIcon)
		Tool.Modes.DYE:
			select_tool($HairDyeIcon)
		Tool.Modes.ROGAINE:
			select_tool($RogaineIcon)
		Tool.Modes.FIRE_EXTINGUISHER:
			select_tool($FireExtinguisherIcon)
	pass
