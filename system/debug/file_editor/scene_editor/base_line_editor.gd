extends VBoxContainer

"""
Base for VN game scene line editor
"""

signal move_up
signal move_down
signal line_changed
signal delete

var extra_buttons_container = HBoxContainer.new()
var editable_area = Control.new()
var line : Dictionary

func _ready():
	var hbox_container := HBoxContainer.new()
	add_child(hbox_container)
	
	var up_button := Button.new()
	var down_button := Button.new()
	var delete_button := Button.new()
	
	up_button.text = tr("Arriba")
	down_button.text = tr("Abajo")
	delete_button.text = tr("Borrar")
	
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