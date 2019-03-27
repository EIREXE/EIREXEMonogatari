extends Control

"""
Base game class, takes care of loading and saving from file, and holds the state
"""

class_name SugarGame

var state := {
	
}

const VNScene = preload("res://system/vn/vn.tscn")

const GAME_ROOT = "res://game/"

var game_info : Dictionary
var backgrounds := []
var characters := {}

var game_state_format = "game_state"

const BASE_SCENE = "res://game/scenes/main.json"
var vn

func init_state():
	state = SJSON.get_format_defaults(game_state_format)
	if state.has("error"):
		push_error("error initializing game state")
	
func list_backgrounds():
	var dir := Directory.new()
	dir.open(GAME_ROOT + "backgrounds")
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "jpg" or file_path.get_extension() == "png":
			backgrounds.append(file_path)
	dir.list_dir_end()
	
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
	
	
func list_characters():
	var dir := Directory.new()
	dir.open(GAME_ROOT + "characters")
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "json":
			var result = SJSON.from_file(GAME_ROOT + "characters/" + file_path)
			if not result.has("error"):
				characters[file_path.get_basename()] = result
	dir.list_dir_end()
	
func run_vn_scene_from_file(scene_path: String):
	var scene = SJSON.from_file(scene_path)
	run_vn_scene(scene)
	
func run_vn_scene(scene: Dictionary):
	vn.show()
	
	# Stretch mode shenanigans to ensure wea re using the proper one
	var stretch_mode = SceneTree.STRETCH_MODE_DISABLED
	var stretch_mode_setting = ProjectSettings.get_setting("display/window/stretch/mode")
	
	if stretch_mode_setting == "2d":
		stretch_mode = SceneTree.STRETCH_MODE_2D
	elif stretch_mode_setting == "viewport":
		stretch_mode = SceneTree.STRETCH_MODE_VIEWPORT
	var aspect_mode_settings = ProjectSettings.get_setting("display/window/stretch/aspect")
	
	var aspect_mode = SceneTree.STRETCH_ASPECT_IGNORE
	
	if aspect_mode_settings == "keep":
		aspect_mode = SceneTree.STRETCH_ASPECT_KEEP
	if aspect_mode_settings == "keep_width":
		aspect_mode = SceneTree.STRETCH_ASPECT_KEEP_WIDTH
	if aspect_mode_settings == "keep_height":
		aspect_mode = SceneTree.STRETCH_ASPECT_KEEP_HEIGHT
	if aspect_mode_settings == "expand":
		aspect_mode = SceneTree.STRETCH_ASPECT_EXPAND
	
	
	var size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	
	get_tree().set_screen_stretch(stretch_mode, aspect_mode, size)
	vn.run_scene(scene)
	
func run_minigame(minigame):
	vn.hide()
	GameManager.set_node_as_current_scene(minigame)
	
func init_game():
	init_state()
	reload_game()
	if vn:
		vn.queue_free()
	vn = VNScene.instance()
	vn.game = self
	add_child(vn)
	vn.hide()
	
func _ready():
	init_state()
	set_anchors_and_margins_preset(Control.PRESET_WIDE)