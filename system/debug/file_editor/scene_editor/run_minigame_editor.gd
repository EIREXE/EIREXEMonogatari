extends "base_line_editor.gd"

var file_selector := FileDialog.new()

var path_preview := LineEdit.new()

func _ready():
	file_selector.add_filter("*.tscn; TSCN")
	file_selector.add_filter("*.gd; GDScript")
	file_selector.mode = FileDialog.MODE_OPEN_FILE
	file_selector.connect("file_selected", self, "_on_file_selected")
	add_child(file_selector)
	
	path_preview.editable = false
	path_preview.text = line.path
	path_preview.rect_min_size = Vector2(100, 0)
	extra_buttons_container.add_child(path_preview)
	
	var select_file_button = Button.new()
	select_file_button.text = tr("SCENE_EDITOR_SELECT_FILE")
	select_file_button.connect("button_down", file_selector, "popup_centered_ratio", [0.75])
	extra_buttons_container.add_child(select_file_button)
	
func _on_file_selected(path: String):
	line.path = path
	path_preview.text = line.path
	.update_line()