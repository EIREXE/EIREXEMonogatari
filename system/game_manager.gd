extends Node

"""
Manages global game state
"""

const SugarToolsMenu = preload("debug/ToolsMenu.gd")

var tools_menu := SugarToolsMenu.new()
var current_scene setget ,_get_current_scene

var game

func _get_current_scene():
	if current_scene:
		return current_scene
	else:
		return get_tree().current_scene

# Handles game initialization

func _ready():
	var debug_canvas_layer := CanvasLayer.new()
	game = load("res://game/game.gd").new()
	game.init_game()
	add_child(game)
	
	debug_canvas_layer.add_child(tools_menu)
	add_child(debug_canvas_layer)
	
	# Editor mode check
	
	if OS.has_feature("sugareditor") or "--sugar-editor" in  OS.get_cmdline_args():
		tools_menu.show_menu()
		
func free_current_scene():
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	if current_scene:
		current_scene.queue_free()

func set_node_as_current_scene(scene: Node):
	get_tree().get_root().add_child(scene)
	free_current_scene()
	current_scene = scene

func change_scene_to(scene_packed: PackedScene):
	var scene = scene_packed.instance()
	set_node_as_current_scene(scene)
	return current_scene
