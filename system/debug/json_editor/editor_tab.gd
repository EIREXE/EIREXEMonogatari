extends MarginContainer

class_name SugarEditorTab

signal contents_changed

var text_edit : TextEdit

var content : String setget set_content
var path : String setget set_path

func set_content(_content: String) -> void:
	content = _content
	text_edit.text = content
	
func set_path(_path: String) -> void:
	path = _path
	var data := SJSON.from_file(path)
	set_content(JSON.print(data, "  "))
	
func setup_syntax_highlighting():
	text_edit.add_color_region("\"", "\"", Color("#ffcf7d34"))
	text_edit.add_keyword_color("true", Color("#ffcc8242"))
	
func on_text_changed():
	content = text_edit.text
	
func _ready():
	margin_top = 20
	text_edit = TextEdit.new()
	text_edit.syntax_highlighting = true
	text_edit.show_line_numbers = true
	text_edit.connect("text_changed", self, "on_text_changed")
	add_child(text_edit)
	setup_syntax_highlighting()