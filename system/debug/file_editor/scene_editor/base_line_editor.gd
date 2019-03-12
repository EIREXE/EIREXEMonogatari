extends VSplitContainer

var extra_buttons_container = HBoxContainer.new()
var editable_area = Control.new()
func _ready():
	var hbox_container := HBoxContainer.new()
	add_child(hbox_container)
	
	var up_button := Button.new()
	var down_button := Button.new()
	
	up_button.text = tr("Up")
	down_button.text = tr("Down")
	
	hbox_container.add_child(up_button)
	
	hbox_container.add_child(extra_buttons_container)
	
	add_child(editable_area)