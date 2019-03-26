extends Node

"""
Manages global game state
"""

signal game_reloaded

const SugarToolsMenu = preload("debug/ToolsMenu.gd")
const VNScene = preload("res://system/vn/vn.tscn")

const GAME_ROOT = "res://game/"

var game_info : Dictionary
var backgrounds := []
var characters := {}
var tools_menu := SugarToolsMenu.new()

var current_scene setget ,_get_current_scene

func _get_current_scene():
	if current_scene:
		return current_scene
	else:
		return get_tree().current_scene

func list_backgrounds():
	var dir := Directory.new()
	dir.open("res://game/backgrounds")
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "jpg" or file_path.get_extension() == "png":
			backgrounds.append(file_path)
	dir.list_dir_end()

# Handles game initialization

func _ready():
	var debug_canvas_layer := CanvasLayer.new()
	debug_canvas_layer.add_child(tools_menu)
	add_child(debug_canvas_layer)
	reload_game()
	
	# Editor mode check
	
	if OS.has_feature("sugareditor"):
		tools_menu.show_menu()
func change_scene_to(scene_packed: PackedScene):
	var scene = scene_packed.instance()
	get_tree().get_root().add_child(scene)
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	if current_scene:
		current_scene.queue_free()
	current_scene = scene
	
	return current_scene
	
func run_vn_scene_from_file(scene_path: String):
	var scene = SJSON.from_file(scene_path)
	run_vn_scene(scene)
	
func run_vn_scene(scene: Dictionary):
	var vn_scene = change_scene_to(VNScene)
	var stretch_mode = get_tree().STRETCH_MODE_DISABLED
	var stretch_mode_setting = ProjectSettings.get_setting("display/window/stretch/mode")
	
	if stretch_mode_setting == "2d":
		stretch_mode = get_tree().STRETCH_MODE_2D
	elif stretch_mode_setting == "viewport":
		stretch_mode = get_tree().STRETCH_MODE_VIEWPORT
	var aspect_mode_settings = ProjectSettings.get_setting("display/window/stretch/aspect")
	
	var aspect_mode = get_tree().STRETCH_ASPECT_IGNORE
	
	if aspect_mode_settings == "keep":
		aspect_mode = get_tree().STRETCH_ASPECT_KEEP
	if aspect_mode_settings == "keep_width":
		aspect_mode = get_tree().STRETCH_ASPECT_KEEP_WIDTH
	if aspect_mode_settings == "keep_height":
		aspect_mode = get_tree().STRETCH_ASPECT_KEEP_HEIGHT
	if aspect_mode_settings == "expand":
		aspect_mode = get_tree().STRETCH_ASPECT_EXPAND
	
	
	var size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

	get_tree().set_screen_stretch(stretch_mode, aspect_mode, size)
	vn_scene.run_scene(scene)
	
func list_characters():
	var dir := Directory.new()
	dir.open("res://game/characters")
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "json":
			var result = SJSON.from_file("res://game/characters/" + file_path)
			if not result.has("error"):
				characters[file_path.get_basename()] = result
	dir.list_dir_end()
	
# Reloads game data, silent mode doesn't emit a signal
func reload_game(silent: bool = false):
	list_backgrounds()
	list_characters()
	game_info = SJSON.from_file(GAME_ROOT + "game_config.json")
	var title : String = ProjectSettings.get_setting("application/config/name")
	if not game_info.has("error"):
		title = game_info["name"]
	else:
		print("ERROR Loading game config file: %s" % game_info["error"])
		
	if OS.is_debug_build():
		title += " (Debug) - " + tr("GAME_WINDOW_DEBUG_HINT")
	
	OS.set_window_title(title)
	
	if not silent:
		emit_signal("game_reloaded")