extends Control

const MAIN_MENU_SCENE = preload("res://system/menus/main_menu.tscn")

func _ready():
	GameManager.set_node_as_current_scene(MAIN_MENU_SCENE.instance())