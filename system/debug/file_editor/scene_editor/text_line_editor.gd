extends "base_line_editor.gd"

var line_text = TextEdit.new()

func _ready():
	editable_area.add_child(line_text)
	line_text.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	rect_min_size = Vector2(0, 100)