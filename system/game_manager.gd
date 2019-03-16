extends Node

const SugarToolsMenu = preload("debug/ToolsMenu.gd")

var game_info : Dictionary
var backgrounds := []
var tools_menu = SugarToolsMenu.new()

const GAME_ROOT = "res://game/"

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

func _ready():
	add_child(tools_menu)
	game_info = SJSON.from_file(GAME_ROOT + "game_config.json")
	var title : String = ProjectSettings.get_setting("application/config/name")
	if not game_info.has("error"):
		title = game_info["name"]
	else:
		print("ERROR Loading game config file: %s" % game_info["error"])
		
	if OS.is_debug_build():
		title += " (Debug)"
	
	OS.set_window_title(title)
	
	list_backgrounds()
	
	
func run_scene(scene_path: String):
	var scene = SJSON.from_file(scene_path)