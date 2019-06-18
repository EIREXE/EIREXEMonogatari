extends Control

signal open_submenu
signal exit_submenu

onready var menu_options_container = get_node("MarginContainer/MainMenu")
onready var submenu_container = get_node("SubMenuUI/SubMenu")
onready var submenu_vbox = get_node("SubMenuUI")
onready var submenu_back_button = get_node("SubMenuUI/HBoxContainer/Button")
onready var main_menu_margin_container = get_node("MarginContainer")

const SubmenuButton = preload("res://system/menus/submenu_button.gd")

var current_submenu
func _ready():
	submenu_vbox.hide()
	for option in menu_options_container.get_children():
		if option is SubmenuButton:
			option.connect("pressed", self, "_open_submenu", [option.submenu_scene])

	submenu_back_button.connect("pressed", self, "_submenu_back")

func _open_submenu(submenu: PackedScene):
	current_submenu = submenu.instance()
	submenu_container.add_child(current_submenu)
	main_menu_margin_container.hide()
	submenu_vbox.show()
	emit_signal("open_submenu")


func _submenu_back():
	if current_submenu.has_method("_submenu_back"):
		current_submenu._submenu_back()
	submenu_vbox.hide()
	current_submenu.queue_free()
	main_menu_margin_container.show()
	emit_signal("exit_submenu")
func _on_new_game():
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)