extends Control

"""
Base game class, takes care of loading and saving from file, and holds the state
"""

class_name SugarGame

var state := {
	
}

const VNScene = preload("res://system/vn/vn.tscn")

const GAME_ROOT = "res://game/"
var pause_menu = preload("res://system/menus/pause_menu.tscn").instance()
var game_info : Dictionary
var backgrounds := []
var characters := {}

signal game_reloaded

var game_state_format = "game_state"

const BASE_SCENE = "res://game/scenes/main.json"

const SAVE_DIRECTORY = "user://saves"

var vn

var current_minigame
var current_minigame_path
var current_scene

var is_in_game = false

var vn_container = Control.new()

func init_state():
	state = SJSON.get_format_defaults(game_state_format)
	if state.has("error"):
		push_error("error initializing game state")
	for character in characters:
		state.characters[character] = characters[character].name
	
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
	current_scene = scene_path
	run_vn_scene(scene)
	
func kill_minigame():
	if current_minigame:
		current_minigame.free()
		current_minigame = null
	
func run_vn_scene(scene: Dictionary):
	is_in_game = true
	vn.show()
	vn.tie.show_buttons()
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
	GameManager.free_current_scene()
	
# Runs the minigame, path is necessary so it can be reloaded when deserialized
func run_minigame(minigame: Node, path: String):
	current_minigame = minigame
	current_minigame.pause_mode = Node.PAUSE_MODE_STOP
	current_minigame.show()
	vn.minigame_container.add_child(minigame)
	is_in_game = true
func init_game():
	reload_game()
	init_state()
	if vn:
		vn.queue_free()
	vn = VNScene.instance() as Node
	vn.game = self
	vn_container.add_child(vn)
	vn.hide()
	vn.pause_mode = PAUSE_MODE_STOP
	is_in_game = false
	
func _ready():
	set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	vn_container.name = "Sugar VN"
	add_child(vn_container)
	vn_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	var dir = Directory.new()
	# Create save directory so we can write and save to it
	dir.make_dir_recursive(SAVE_DIRECTORY)
	
	if get_tree().current_scene is SugarMinigame:
		var minigame = get_tree().current_scene
		get_tree().root.call_deferred("remove_child", minigame)
		call_deferred("run_minigame", minigame)
		
	pause_mode = PAUSE_MODE_PROCESS
	pause_menu.hide()
	add_child(pause_menu)
func _serialize_game():
	var serialized_game = {
			"game_state": state,
			"current_minigame": current_minigame_path,
			"current_scene": current_scene,
			"current_line": vn.current_line
		}
		
	return serialized_game
	
func _load_from_serialized_game(game_save: Dictionary):
	state = game_save.game_state
	if game_save.current_minigame:
		var new_minigame_class = load(game_save.current_minigame)
		var new_minigame
		if new_minigame_class is PackedScene:
			new_minigame = new_minigame_class.instance()
		else:
			new_minigame = new_minigame_class.new()
		run_minigame(new_minigame, game_save.current_minigame)
	elif game_save.current_scene:
		run_vn_scene_from_file(game_save.current_scene)
		vn.fast_forward_to_line(game_save.current_line)
		
func pause_game():
	get_tree().paused = true
	pause_menu.show_pause()
	
func resume_game():
	get_tree().paused = false
	pause_menu.hide()
func _input(event: InputEvent):
	if event.is_action_pressed("pause_game") and not event.is_echo():
		if get_tree().paused:
			pause_menu._on_game_resumed()
		else:
			pause_game()
func save_game(path: String):
	var file = File.new()
	file.open(File.WRITE)
	file.store_string(JSON.print(_serialize_game(), "  "))