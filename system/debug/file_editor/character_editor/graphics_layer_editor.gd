extends HBoxContainer

"""
Editor for graphics layer
"""
signal move_up(idx)
signal move_down(idx)
signal delete(idx)
signal layer_changed(idx)

var layer_data : Dictionary
var layer_name := LineEdit.new()

func _ready():
	add_child(layer_name)
	layer_name.text = layer_data.name
	
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
	add_child(up_button)
	add_child(down_button)
	add_child(edit_button)
	add_child(delete_button)
	
	layer_name.size_flags_horizontal = SIZE_EXPAND_FILL
	layer_name.connect("text_changed", self, "_on_layer_name_change")
	
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
	emit_signal("layer_changed", get_position_in_parent())
func delete():
	emit_signal("delete", get_position_in_parent())
	queue_free()