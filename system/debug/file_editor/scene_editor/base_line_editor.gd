extends VBoxContainer

"""
Base for VN game scene line editor
"""
# BRBBBB
signal move_up
signal move_down
signal line_changed
signal delete

var extra_buttons_container = HBoxContainer.new()
var editable_area = Control.new()
var line : Dictionary
var scene_editor

func _ready():
	var hbox_container := HBoxContainer.new()
	add_child(hbox_container)
	
	var up_button := Button.new()
	var down_button := Button.new()
	var delete_button := Button.new()
	
	up_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_UP")
	down_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_DOWN")
	delete_button.hint_tooltip = tr("EDITOR_HINT_BUTTON_DELETE")
	
	up_button.icon = ImageTexture.new()
	up_button.icon.load("res://system/debug/file_editor/icons/icon_move_up.svg")
	down_button.icon = ImageTexture.new()
	down_button.icon.load("res://system/debug/file_editor/icons/icon_move_down.svg")
	delete_button.icon = ImageTexture.new()
	delete_button.icon.load("res://system/debug/file_editor/icons/icon_remove.svg")
	
	up_button.connect("button_down", self, "move_position_up")
	down_button.connect("button_down", self, "move_position_down")
	delete_button.connect("button_down", self, "delete")
	hbox_container.add_child(up_button)
	hbox_container.add_child(down_button)
	hbox_container.add_child(delete_button)
	hbox_container.add_child(extra_buttons_container)
	
	size_flags_vertical = SIZE_EXPAND_FILL
	
	add_child(editable_area)
	editable_area.size_flags_vertical = SIZE_EXPAND_FILL
	
func move_position_up():
	if get_position_in_parent() > 0:
		emit_signal("move_up", get_position_in_parent())
		get_parent().move_child(self, get_position_in_parent()-1)
		
func move_position_down():
	if get_position_in_parent()+1 != get_parent().get_child_count():
		emit_signal("move_down", get_position_in_parent())
		get_parent().move_child(self, get_position_in_parent()+1)
		
func delete():
	emit_signal("delete", get_position_in_parent())
	queue_free()
		
func update_line():
	emit_signal("line_changed", get_position_in_parent(), line)