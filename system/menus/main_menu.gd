extends Control

onready var menu_options_container = get_node("Control/MarginContainer/MainMenu")
onready var main_menu_margin_container = get_node("Control/MarginContainer")
onready var game_label = get_node("Label")
func _ready():

	game_label.text = GameManager.game.game_info.name

func _on_new_game():
	print("NEW GAME")
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)