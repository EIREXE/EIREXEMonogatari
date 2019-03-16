extends Node

const SugarToolsMenu = preload("debug/ToolsMenu.gd")

var game_info : Dictionary
var backgrounds := []
var characters := {}
var tools_menu = SugarToolsMenu.new()

const VNScene = preload("res://system/vn/vn.tscn")

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
	reload_game()
	
func run_scene(scene_path: String):
	var scene = SJSON.from_file(scene_path)
	get_tree().current_scene.queue_free()
	var vn_scene = VNScene.instance()
	get_tree().get_root().add_child(vn_scene)
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
	
func reload_game():
	list_backgrounds()
	list_characters()
	game_info = SJSON.from_file(GAME_ROOT + "game_config.json")
	var title : String = ProjectSettings.get_setting("application/config/name")
	if not game_info.has("error"):
		title = game_info["name"]
	else:
		print("ERROR Loading game config file: %s" % game_info["error"])
		
	if OS.is_debug_build():
		title += " (Debug)"
	
	OS.set_window_title(title)