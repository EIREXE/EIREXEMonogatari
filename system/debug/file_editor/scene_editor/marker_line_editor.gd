extends "base_line_editor.gd"

var file_selector := FileDialog.new()

var label_input := LineEdit.new()

func _ready():
	
	label_input.text = line.name
	label_input.rect_min_size = Vector2(100, 0)
	label_input.connect("text_changed", self, "_on_marker_name_changed")
	extra_buttons_container.add_child(label_input)
	
func _on_marker_name_changed(name: String):
	line.name = name
	.update_line()