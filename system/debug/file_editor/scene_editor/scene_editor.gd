extends SugarEditorFile

var LINE_TYPES : Dictionary = {
	"text_line": {
		"name": tr("Linea de texto"),
		"editor": preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")
	},
	"background_change_line": {
		"name": tr("Cambio de fondo"),
		"editor": preload("res://system/debug/file_editor/scene_editor/background_change_editor.gd")
	}
}

var line_hbox_container = VBoxContainer.new()
var add_shortcut_menubutton : MenuButton
const TextLineEditor = preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")

var scene : Dictionary = { "lines": [] }
func _ready():
	var vbox_container := VBoxContainer.new()
	var buttons_container := HBoxContainer.new()
	
	# Line addition button
	
	vbox_container.add_child(buttons_container)
	
	add_shortcut_menubutton = MenuButton.new()
	add_shortcut_menubutton.text = "+"
	add_shortcut_menubutton.flat = false
	
	buttons_container.alignment = HBoxContainer.ALIGN_END
	
	buttons_container.add_child(add_shortcut_menubutton)
	
	for i in LINE_TYPES:
		var line_shortcut = ShortCut.new()
		line_shortcut.set_name(LINE_TYPES[i].name)
		line_shortcut.set_meta("line_type", i)
		add_shortcut_menubutton.get_popup().add_shortcut(line_shortcut)
		
	add_shortcut_menubutton.get_popup().connect("index_pressed", self, "add_new_line")
	
	# Base scroll container
	
	var scroll_container := ScrollContainer.new()
	add_child(vbox_container)
	vbox_container.add_child(scroll_container)
	scroll_container.add_child(line_hbox_container)
	scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	line_hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
	
func swap_lines(idx1: int, idx2: int):
	var temp : Dictionary = scene.lines[idx1]
	scene.lines[idx1] = scene.lines[idx2]
	scene.lines[idx2] = temp
	
func move_line_up(line_idx: int):
	swap_lines(line_idx, line_idx-1)
func move_line_down(line_idx: int):
	swap_lines(line_idx, line_idx+1)
func add_new_line(shortcut_id: int):
	if not scene.has("lines"):
		scene["lines"] = []
	var line_type_name : String = add_shortcut_menubutton.get_popup().get_item_shortcut(shortcut_id).get_meta("line_type")
	var line_type : Dictionary = LINE_TYPES[line_type_name]
	var line_editor = line_type.editor.new()
	var line = SJSON.get_format_defaults(line_type_name)
	line_editor.line = line
	line_hbox_container.add_child(line_editor)
	
	scene.lines.append(line)
	
	line_editor.connect("line_changed", self, "on_line_changed")
	line_editor.connect("move_up", self, "move_line_up")
	line_editor.connect("move_down", self, "move_line_down")
	line_editor.connect("delete", self, "delete_line")
	
func on_line_changed(idx: int, new_line):
	scene.lines[idx] = new_line
func set_content(_content):
	content = _content
	scene = JSON.parse(_content).result
	
func delete_line(idx):
	scene.lines.remove(idx)
	
func get_content():
	return JSON.print(scene, "  ")