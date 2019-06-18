extends PopupPanel

enum Mode {
		LOAD,
		SAVE
	}

onready var game = GameManager.game

export(Mode) var mode = Mode.SAVE

onready var save_new_game_button = get_node("MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/SaveNewGameButton")
onready var overwrite_confirmation_dialog = get_node("OverwriteConfirmationDialog")
onready var title_label = get_node("MarginContainer/VBoxContainer/Label")

onready var save_game_buttons = get_node("MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/SaveGameButtons")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("about_to_show", self, "_on_about_to_show")
	save_new_game_button.connect("pressed", self, "_on_save_new_game")
	overwrite_confirmation_dialog.connect("confirmed", self, "hide")
func _on_about_to_show() -> void:
	var saves = game.save_manager.get_saves()
	save_new_game_button.hide()
	
	for child in save_game_buttons.get_children():
		child.free()
	
	match mode:
		Mode.SAVE:
			save_new_game_button.show()
			title_label.text = tr("GAME_GENERIC_SAVE_GAME")
		Mode.LOAD:
			title_label.text = tr("GAME_GENERIC_LOAD_GAME")
	for save_id in saves:
		var save = saves[save_id]
		var save_button = Button.new()
		save_button.text = game.save_manager.get_save_display_name(save)
		save_button.focus_mode = Control.FOCUS_NONE
		save_button.connect("pressed", self, "_on_save_game_selected", [save, save_id])
		save_game_buttons.add_child(save_button)
func _on_save_game_selected(save: Dictionary, id: String) -> void:
	match mode:
		Mode.SAVE:
			if overwrite_confirmation_dialog.is_connected("confirmed", game.save_manager, "save_current_game"):
				overwrite_confirmation_dialog.disconnect("confirmed", game.save_manager, "save_current_game")
			overwrite_confirmation_dialog.connect("confirmed", game.save_manager, "save_current_game", [id])
			overwrite_confirmation_dialog.popup_centered()
		Mode.LOAD:
			game.save_manager.load_game(save, id)
			hide()
	
func _on_save_new_game():
	game.save_manager.save_current_game(game.save_manager.generate_save_id())
	hide()
	emit_signal("game_saved")
