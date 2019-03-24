extends HBoxContainer

"""
Editor for graphics layer
"""
signal move_up(idx)
signal move_down(idx)
signal delete(name)
signal layer_changed(name, data)
signal layer_internal_name_changed(idx, new_name)

var character setget _set_character

var layer_data : Dictionary
var layer_internal_name_editor := LineEdit.new()
var layer_name := LineEdit.new()
var selector_window := preload("res://system/debug/file_editor/character_editor/graphic_layer_graphic_selector_dialog.gd").new()

var layer_internal_name : String
func _ready():
	add_child(selector_window)
	selector_window.connect("graphics_selected", self, "_on_graphics_selected")
	selector_window.popup_exclusive = true
	var up_button := Button.new()
	var edit_button := Button.new()
	var down_button := Button.new()
	var delete_button := Button.new()
	
	up_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_UP")
	down_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_DOWN")
	delete_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_DELETE")
	edit_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_EDIT")
	
	edit_button.icon = ImageTexture.new()
	edit_button.icon.load("res://system/debug/file_editor/icons/icon_edit.svg")
	
	up_button.icon = ImageTexture.new()
	up_button.icon.load("res://system/debug/file_editor/icons/icon_move_up.svg")
	
	down_button.icon = ImageTexture.new()
	down_button.icon.load("res://system/debug/file_editor/icons/icon_move_down.svg")
	delete_button.icon = ImageTexture.new()
	delete_button.icon.load("res://system/debug/file_editor/icons/icon_remove.svg")
	
	up_button.connect("button_down", self, "move_position_up")
	down_button.connect("button_down", self, "move_position_down")
	delete_button.connect("button_down", self, "delete")
	edit_button.connect("button_down", self, "_on_edit")
	
	add_child(up_button)
	add_child(down_button)
	add_child(edit_button)
	add_child(delete_button)
	add_child(layer_internal_name_editor)
	layer_internal_name_editor.placeholder_text = tr("CHARACTER_EDITOR_LAYER_INTERNAL_NAME")
	layer_name.placeholder_text = tr("CHARACTER_EDITOR_LAYER_NAME")
	add_child(layer_name)
	layer_name.text = layer_data.name
	layer_internal_name_editor.text = layer_internal_name
	layer_name.size_flags_horizontal = SIZE_EXPAND_FILL
	layer_internal_name_editor.size_flags_horizontal = SIZE_EXPAND_FILL
	layer_name.connect("text_changed", self, "_on_layer_name_change")
	layer_internal_name_editor.connect("text_changed", self, "_on_layer_internal_name_change")
	
func move_position_up():
	if get_position_in_parent() > 0:
		emit_signal("move_up", get_position_in_parent())
		get_parent().move_child(self, get_position_in_parent()-1)
		
func move_position_down():
	if get_position_in_parent()+1 != get_parent().get_child_count():
		emit_signal("move_down", get_position_in_parent())
		get_parent().move_child(self, get_position_in_parent()+1)
		
func _on_layer_name_change(text):
	layer_data.name = layer_name.text
	emit_signal("layer_changed", layer_internal_name, layer_data)
	
func _on_layer_internal_name_change(new_name: String):
	layer_internal_name = new_name
	emit_signal("layer_internal_name_changed", get_position_in_parent(), new_name)
	
func _on_graphics_selected(graphics: Array):
	layer_data.graphics = graphics
	emit_signal("layer_changed", layer_internal_name, layer_data)
	
func _set_character(_character):
	character = _character
	
func _on_edit():
	selector_window.load_character_graphics(character)
	selector_window.select_graphics(layer_data.graphics)
	selector_window.popup_centered_ratio(0.25)
func delete():
	emit_signal("delete", layer_internal_name)
	queue_free()