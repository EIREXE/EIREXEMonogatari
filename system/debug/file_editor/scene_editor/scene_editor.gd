extends SugarEditorFile

var LINE_TYPES : Dictionary = {
	"text_line": {
		"name": tr("Linea de texto"),
		"editor": preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")
	}
}

func _ready():
	var hbox_container := HBoxContainer.new()
	var scroll_container := ScrollContainer.new()
	add_child(hbox_container)
	hbox_container.add_child(scroll_container)
	var line_hbox_container = HBoxContainer.new()
	scroll_container.add_child(line_hbox_container)
	line_hbox_container.size_flags_vertical = SIZE_EXPAND_FILL
	
	