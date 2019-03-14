extends SugarEditorFile

var LINE_TYPES : Dictionary = {
	"text_line": {
		"name": tr("Linea de texto"),
		"editor": preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")
	}
}

var line_hbox_container = VBoxContainer.new()
const TextLineEditor = preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")
func _ready():
	var hbox_container := VBoxContainer.new()
	var scroll_container := ScrollContainer.new()
	add_child(hbox_container)
	hbox_container.add_child(scroll_container)
	scroll_container.add_child(line_hbox_container)
	scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	line_hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
	var label = Label.new()
	label.text = "dab"
	line_hbox_container.add_child(TextLineEditor.new())
	line_hbox_container.add_child(TextLineEditor.new())
	line_hbox_container.add_child(TextLineEditor.new())
	line_hbox_container.add_child(TextLineEditor.new())
	line_hbox_container.add_child(TextLineEditor.new())