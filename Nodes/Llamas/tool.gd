@tool
extends Node2D

# Click this checkbox in the Inspector to take the picture
@export var bake_sprite: bool = false:
	set(value):
		_on_bake_pressed()

# Path to find the viewport inside your studio setup
@onready var viewport: SubViewport = $SubViewportContainer/SubViewport

func _on_bake_pressed():
	# Safety guard: only execute while working inside the editor
	if not Engine.is_editor_hint():
		return

	if not is_inside_tree(): 
		return
		
	if viewport:
		var img = viewport.get_texture().get_image()
		
		# Ensure the image data is valid before saving
		if img == null or img.is_empty():
			print("Error: Viewport texture image is empty.")
			return
			
		var save_path = "res://generated_character_sprite.png"
		var error = img.save_png(save_path)
		
		if error == OK:
			print("Character sprite saved successfully to: ", save_path)
			print("💡 Click on the Godot window or the FileSystem tab to force a quick refresh!")
		else:
			print("Failed to save image. Error code: ", error)
