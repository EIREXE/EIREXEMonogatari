extends Control

onready var menu_options_container = get_node("MarginContainer/MainMenu")
onready var submenu_container = get_node("SubMenuUI/SubMenu")
onready var submenu_vbox = get_node("SubMenuUI")
onready var submenu_back_button = get_node("SubMenuUI/Panel/HBoxContainer/Button")
onready var main_menu_margin_container = get_node("MarginContainer")
onready var game_label = get_node("Label")
var current_submenu
func _ready():
	submenu_vbox.hide()
	for option in menu_options_container.get_children():
		option.connect("pressed", self, "_open_submenu", [option.submenu_scene])
	
	# Add default buttons

	
	var separator = Control.new()
	separator.rect_min_size.y = 75
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
	
	submenu_back_button.connect("pressed", self, "_submenu_back")
	
func _open_submenu(submenu: PackedScene):
	current_submenu = submenu.instance()
	submenu_container.add_child(current_submenu)
	main_menu_margin_container.hide()
	submenu_vbox.show()
	game_label.hide()
	
func _submenu_back():
	if current_submenu.has_method("_submenu_back"):
		current_submenu._submenu_back()
	submenu_vbox.hide()
	current_submenu.queue_free()
	main_menu_margin_container.show()
	game_label.show()
		
func _on_new_game():
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)