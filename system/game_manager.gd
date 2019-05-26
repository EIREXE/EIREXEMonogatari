extends Node

"""
Manages global game state
"""

const SugarToolsMenu = preload("debug/ToolsMenu.gd")

var tools_menu := SugarToolsMenu.new()
var current_scene setget ,_get_current_scene

var game

var user_settings
const USER_SETTINGS_PATH = "user://settings.json"

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
	
	
	debug_canvas_layer.add_child(tools_menu)
	add_child(debug_canvas_layer)
	add_child(game)
	# Editor mode check
	
	if OS.has_feature("sugareditor") or "--sugar-editor" in  OS.get_cmdline_args():
		tools_menu.show_menu()
		
	var file = File.new()
	
	user_settings = SJSON.get_format_defaults("user_settings")
	
	if file.file_exists(USER_SETTINGS_PATH):
		var tmp_user_settings = SJSON.from_file(USER_SETTINGS_PATH)
		if not tmp_user_settings.has("error"):
			user_settings = tmp_user_settings
	else:
		save_user_settings()
			
	if user_settings.locale:
		TranslationServer.set_locale(user_settings.locale)
			
func save_user_settings():
	var file = File.new()
	file.open(USER_SETTINGS_PATH, File.WRITE)
	file.store_string(JSON.print(user_settings, "  "))
	file.close()
func free_current_scene():
	if _get_current_scene():
		_get_current_scene().queue_free()
		current_scene = null

func set_node_as_current_scene(scene: Node):
	free_current_scene()
	get_tree().get_root().call_deferred("add_child", scene)
	current_scene = scene

func change_scene_to(scene_packed: PackedScene):
	var scene = scene_packed.instance()
	set_node_as_current_scene(scene)
	return current_scene
