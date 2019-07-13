extends Node
onready var game = GameManager.game

const SAVE_DIRECTORY := "user://saves/"

const SugarVN := preload("res://system/vn/vn.gd")
const UUID := preload("res://system/uuid.gd")

func generate_save_id():
	return UUID.v4()

func save_current_game(name: String) -> void:
	save_game(name, game.serialize_game())
func save_game(save_id: String, save_game: Dictionary):
	var file := File.new()
	var save_path := SAVE_DIRECTORY + "{0}.sgr".format([save_id])
	print(save_path)
	file.open(save_path, File.WRITE)
	file.store_string(JSON.print(save_game, "  "))
	file.close()
func get_save_display_name(save: Dictionary) -> String:
	# Format is the same as VN state prints: "{characters/nina} and {characters/chris}, {days_passed} together."
	var display_name_translation_key := "GAME_SAVE_DISPLAY_NAME"
	var translated := tr(display_name_translation_key)
	translated = SugarVN.parse_state_prints(translated, save.game_state)
	return translated
	
func _ready():
	var dir = Directory.new()
	# Create save directory so we can write and save to it
	dir.make_dir_recursive(SAVE_DIRECTORY)
func get_saves() -> Dictionary:
	var dir := Directory.new()
	var saves := {}
	if dir.open(SAVE_DIRECTORY) == OK:
		dir.list_dir_begin()
		while true:
			var file_path := dir.get_next()
			if file_path == "":
				break
			elif not file_path.begins_with(".") and file_path.get_extension() == "sgr":
				var file := File.new()
				var file_result := file.open(SAVE_DIRECTORY + file_path, File.READ)
				if file_result == OK:
					var text := file.get_as_text()
					var result := JSON.parse(text)
					if result.error == OK:
						saves[file_path.trim_suffix(".sgr")] = result.result
					else:
						pass
				else:
					pass
		dir.list_dir_end()
	return saves
	
func load_game(save_game: Dictionary, id: String):
	# TODO: Autosave
	game.load_from_serialized_game(save_game)