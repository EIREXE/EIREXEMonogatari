extends Control

onready var menu_options_container = get_node("Control/MarginContainer/MainMenu")
onready var main_menu_margin_container = get_node("Control/MarginContainer")

func _on_new_game():
	print("NEW GAME")
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)
	
func _on_quit_game():
	get_tree().quit()