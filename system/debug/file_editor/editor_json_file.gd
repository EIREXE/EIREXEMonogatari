extends SugarEditorTab

"""
Plain JSON text file editor
"""

signal contents_changed

var text_edit : TextEdit

func set_content(_content: String) -> void:
	content = _content
	text_edit.text = content
	
func setup_syntax_highlighting():
	text_edit.add_color_region("\"", "\"", Color("#ffcf7d34"))
	text_edit.add_keyword_color("true", Color("#ffcc8242"))
	
func on_text_changed():
	content = text_edit.text
	emit_signal("contents_changed")
	
func _ready():
	margin_top = 20
	text_edit = TextEdit.new()
	text_edit.syntax_highlighting = true
	text_edit.show_line_numbers = true
	text_edit.connect("text_changed", self, "on_text_changed")
	add_child(text_edit)
	setup_syntax_highlighting()