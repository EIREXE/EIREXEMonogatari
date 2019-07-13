extends Control

const FIRST_SCENE = preload("res://system/menus/title_branding.tscn")

func _ready():
	GameManager.set_node_as_current_scene(FIRST_SCENE.instance())