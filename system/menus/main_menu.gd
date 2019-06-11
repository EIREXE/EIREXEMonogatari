extends Control

onready var menu_options_container = get_node("Control/MarginContainer/MainMenu")
onready var main_menu_margin_container = get_node("Control/MarginContainer")
onready var game_label = get_node("Label")
func _ready():

	# Add default buttons


	var separator := HSeparator.new()
	separator.add_constant_override("separation", 75)
	menu_options_container.add_child(separator)
	menu_options_container.move_child(separator, 0)

	# load game button

	var load_game_button = Button.new()
	load_game_button.text = tr("GAME_GENERIC_LOAD_GAME")

	menu_options_container.add_child(load_game_button)
	menu_options_container.move_child(load_game_button, 0)

	# new game button

	var new_game_button = Button.new()
	new_game_button.text = tr("GAME_GENERIC_NEW_GAME")

	new_game_button.connect("pressed", self, "_on_new_game")

	menu_options_container.add_child(new_game_button)
	menu_options_container.move_child(new_game_button, 0)

	game_label.text = GameManager.game.game_info.name

func _on_new_game():
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)