extends Control

const MAIN_MENU = preload("res://system/menus/main_menu.tscn")

func _on_quit_to_main_menu():
	$PopupPanel.popup_centered()

func quit_to_main_menu():
	GameManager.game.init_game()
	GameManager.change_scene_to(MAIN_MENU)
	
func _on_game_resumed():
	$ResumeStreamPlayer.play()
	GameManager.game.resume_game()
	
func show_pause():
	show()
	$PauseStreamPlayer.play()