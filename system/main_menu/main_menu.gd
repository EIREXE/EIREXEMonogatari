extends Control

onready var game_title_label = get_node("MarginContainer/VBoxContainer/GameTitle")
onready var new_game_button = get_node("MarginContainer/VBoxContainer/VBoxContainer2/NewGameButton")
func _ready():
	game_title_label.text = GameManager.game.game_info.name
	new_game_button.connect("button_down", self, "_on_new_game")
	
func _on_new_game(): 
	GameManager.game.run_vn_scene_from_file(GameManager.game.BASE_SCENE)
	queue_free()