extends Node

const SugarToolsMenu = preload("debug/ToolsMenu.gd")

var tools_menu = SugarToolsMenu.new()

func _ready():
	add_child(tools_menu)