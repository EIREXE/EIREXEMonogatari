extends SugarEditorTab

"""
Editor for VN scenes
"""

const TextLineEditor = preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")

var LINE_TYPES : Dictionary = {
	"text_line": {
		"name": tr("SCENE_EDITOR_TEXT_LINE"),
		"editor": preload("res://system/debug/file_editor/scene_editor/text_line_editor.gd")
	},
	"background_change_line": {
		"name": tr("SCENE_EDITOR_BACKGROUND_CHANGE_LINE"),
		"editor": preload("res://system/debug/file_editor/scene_editor/background_change_editor.gd")
	},
	"change_character_visibility_line": {
		"name": tr("SCENE_EDITOR_CHARACTER_VISIBILITY_CHANGE"),
		"editor": preload("res://system/debug/file_editor/scene_editor/character_visibility_change_editor.gd")
	}
}

var line_hbox_container = VBoxContainer.new()
var add_line_menubutton : MenuButton
var scene : Dictionary = { "lines": [] }
var code_viewer = TextEdit.new()

var scroll_container := ScrollContainer.new()
var editor_container := VBoxContainer.new()
func _ready():
	var buttons_container := HBoxContainer.new()
	
	# Line addition button
	
	editor_container.add_child(buttons_container)
	
	add_line_menubutton = MenuButton.new()
	add_line_menubutton.flat = false
	add_line_menubutton.icon = ImageTexture.new()
	add_line_menubutton.icon.load("res://system/debug/file_editor/icons/icon_add.svg")
	add_line_menubutton.hint_tooltip = tr("SCENE_EDITOR_HINT_ADD_LINE")
	var view_code_button = Button.new()
	view_code_button.hint_tooltip = tr("SCENE_EDITOR_HINT_VIEW_CODE")
	view_code_button.icon = ImageTexture.new()
	view_code_button.icon.load("res://system/debug/file_editor/icons/icon_script.svg")
	buttons_container.add_child(view_code_button)
	
	view_code_button.connect("button_down", self, "_toggle_code_view")

	var run_scene_button = Button.new()
	run_scene_button.hint_tooltip = tr("SCENE_EDITOR_HINT_RUN_SCENE")
	run_scene_button.icon = ImageTexture.new()
	run_scene_button.icon.load("res://system/debug/file_editor/icons/icon_main_play.svg")
	buttons_container.add_child(run_scene_button)
	
	run_scene_button.connect("button_down", self, "_run_scene")

	buttons_container.add_child(add_line_menubutton)
	
	buttons_container.alignment = HBoxContainer.ALIGN_END
	
	for i in LINE_TYPES:
		var line_shortcut = ShortCut.new()
		line_shortcut.set_name(LINE_TYPES[i].name)
		line_shortcut.set_meta("line_type", i)
		add_line_menubutton.get_popup().add_shortcut(line_shortcut)
		
	add_line_menubutton.get_popup().connect("index_pressed", self, "on_new_line_shortcut_pressed")
	
	# Base scroll container

	add_child(editor_container)
	editor_container.add_child(scroll_container)
	scroll_container.add_child(line_hbox_container)
	scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	line_hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
	
	editor_container.add_child(code_viewer)
	
	code_viewer.size_flags_vertical = SIZE_EXPAND_FILL
	code_viewer.visible = false
	code_viewer.syntax_highlighting = true
	code_viewer.show_line_numbers = true
	code_viewer.add_color_region("\"", "\"", Color("#ffcf7d34"))
	code_viewer.add_keyword_color("true", Color("#ffcc8242"))
	code_viewer.readonly = true
func _toggle_code_view():
	code_viewer.visible = !code_viewer.visible
	scroll_container.visible = !scroll_container.visible
	if code_viewer.visible:
		code_viewer.text = get_content()
	
func swap_lines(idx1: int, idx2: int):
	var temp : Dictionary = scene.lines[idx1]
	scene.lines[idx1] = scene.lines[idx2]
	scene.lines[idx2] = temp
	
func move_line_up(line_idx: int):
	swap_lines(line_idx, line_idx-1)
func move_line_down(line_idx: int):
	swap_lines(line_idx, line_idx+1)
	
func on_new_line_shortcut_pressed(shortcut_id):
	var line_type_name : String = add_line_menubutton.get_popup().get_item_shortcut(shortcut_id).get_meta("line_type")
	var line = SJSON.get_format_defaults(line_type_name)
	scene.lines.append(line)
	add_new_line(line_type_name)
func add_new_line(line_type_name: String, line = null):
	if not scene.has("lines"):
		scene["lines"] = []

	var line_type : Dictionary = LINE_TYPES[line_type_name]
	var line_editor = line_type.editor.new()
	if not line:
		line = SJSON.get_format_defaults(line_type_name)
		
	line_editor.line = line
	line_editor.connect("line_changed", self, "on_line_changed")
	line_hbox_container.add_child(line_editor)
	line_editor.connect("move_up", self, "move_line_up")
	line_editor.connect("move_down", self, "move_line_down")
	line_editor.connect("delete", self, "delete_line")
	
func _run_scene():
	GameManager.run_vn_scene(scene)
	editor_window.hide()
	
func on_line_changed(idx: int, new_line):
	scene.lines[idx] = new_line
func set_content(_content):
	content = _content
	scene = JSON.parse(_content).result
	for child in line_hbox_container.get_children():
		child.queue_free()
	
	for line in scene.lines:
		add_new_line(line.__format, line)
func delete_line(idx):
	scene.lines.remove(idx)
	
func get_content():
	return JSON.print(scene, "  ")