extends Control

const MAIN_MENU = preload("res://system/menus/main_menu.tscn")
onready var save_popup = get_node("SavePopup")
onready var load_popup = get_node("LoadGamePopup")
onready var pause_menu_items = get_node("Control")

func _ready():
	save_popup.connect("hide", self, "_on_game_resumed")

func _on_quit_to_main_menu():
	$PopupPanel.popup_centered()

func quit_to_main_menu():
	GameManager.game.init_game()
	GameManager.change_scene_to(MAIN_MENU)
	GameManager.game.resume_game()
	
func _on_game_resumed():
	$ResumeStreamPlayer.play()
	GameManager.game.resume_game()
	
func show_pause():
	show()
	pause_menu_items.show()
	$PauseStreamPlayer.play()
	
func show_save_game_prompt():
	GameManager.game.pause_game()
	save_popup.popup_centered_ratio(0.50)
	pause_menu_items.hide()
func show_load_game_prompt():
	GameManager.game.pause_game()
	load_popup.popup_centered_ratio(0.50)
	pause_menu_items.hide()