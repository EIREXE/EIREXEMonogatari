extends Control

"""
Extensible, general purpose game data editor
"""

# Paths that will automatically fire a game_reload when saving to them
const AUTO_RELOAD_PATHS = ["res://game"]

onready var tab_container : TabContainer = get_node("Panel/MarginContainer/VBoxContainer/TabContainer")
onready var file_button : MenuButton = get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/FileButton")
onready var help_button : MenuButton = get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/HelpButton")
onready var code_validation_status_label = get_node("Panel/MarginContainer/VBoxContainer/StatusBar/ValidationStatusLabel")
onready var new_format_option_button = get_node("NewFileDialog/HBoxContainer/OptionButton")
onready var new_file_dialog : WindowDialog = get_node("NewFileDialog")
onready var new_file_button : Button = get_node("NewFileDialog/HBoxContainer/NewFileButton")

onready var source_code_button = get_node("AboutDialog/MarginContainer/VBoxContainer/HBoxContainer2/SourceCodeButton")

const SugarJSONEditorTab = preload("res://system/debug/file_editor/editor_json_file.gd")
const SugarSceneEditorTab = preload("res://system/debug/file_editor/scene_editor/scene_editor.gd")
const SugarCharacterEditorTab = preload("res://system/debug/file_editor/character_editor/character_editor.gd")
const SugarOpenCharacterDialog = preload("res://system/debug/file_editor/open_character_dialog.gd")
enum FILE_MENU_OPTIONS {
	NEW_FILE,
	OPEN_FILE,
	OPEN_CHARACTER,
	SAVE_FILE,
	SAVE_FILE_AS,
	CHECK_FILE
}

enum HELP_MENU_OPTIONS {
	ABOUT
}

var file_dialog := FileDialog.new()
var save_file_dialog := FileDialog.new()
var open_files := []
var character_dialog := SugarOpenCharacterDialog.new()

func ui_setup():
	source_code_button.text = tr("EDITOR_SOURCE_CODE")
	
	# Character dialog
	add_child(character_dialog)
	character_dialog.connect("character_selected", self, "_on_character_selected")
	
	add_child(file_dialog)
	add_child(save_file_dialog)
	
	var vb_container := VBoxContainer.new()
	vb_container.size_flags_vertical = SIZE_EXPAND
	
	vb_container.set_anchors_preset(PRESET_WIDE)
	
	file_button.get_popup().add_item(tr("EDITOR_NEW_FILE"), FILE_MENU_OPTIONS.NEW_FILE, KEY_MASK_CTRL | KEY_N)
	file_button.get_popup().add_item(tr("EDITOR_OPEN_FILE"), FILE_MENU_OPTIONS.OPEN_FILE, KEY_MASK_CTRL | KEY_O)
	file_button.get_popup().add_item(tr("EDITOR_OPEN_CHARACTER"), FILE_MENU_OPTIONS.OPEN_CHARACTER, KEY_MASK_CTRL | KEY_P)
	
	file_button.get_popup().add_separator()
	
	file_button.get_popup().add_item(tr("EDITOR_SAVE_FILE"), FILE_MENU_OPTIONS.SAVE_FILE, KEY_MASK_CTRL | KEY_S)
	file_button.get_popup().add_item(tr("EDITOR_SAVE_FILE_AS"), FILE_MENU_OPTIONS.SAVE_FILE_AS, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	
	file_button.get_popup().add_separator()
	
	file_button.get_popup().add_item(tr("EDITOR_CHECK_FILE"), FILE_MENU_OPTIONS.CHECK_FILE)
	
	# Help button
	
	help_button.get_popup().add_item(tr("EDITOR_ABOUT"))
	
	# Popullate the format list
	for key in SJSON.formats:
		var format : Dictionary = SJSON.formats[key]
		var hidden = false
		if format.has("hidden"):
			hidden = format.hidden
		if not hidden:
			new_format_option_button.add_item(format["name"])
			new_format_option_button.set_item_metadata(new_format_option_button.get_item_count() - 1, key)
	file_button.get_popup().connect("id_pressed", self, "on_option_pressed")
	help_button.get_popup().connect("id_pressed", self, "on_help_pressed")
	new_file_button.connect("pressed", self, "on_new_file_button_pressed")
		
func _get_editor_for_format(format: String):
	var format_editor
	if format == "character":
		format_editor = SugarCharacterEditorTab.new()
	elif format == "scene":
		format_editor = SugarSceneEditorTab.new()
	else:
		format_editor = SugarJSONEditorTab.new()
	return format_editor

# Adds a new empty file format
func new_empty_file(format: String) -> SugarEditorTab:
	var defaults = JSON.print(SJSON.get_format_defaults(format), "  ")

	var editor : SugarEditorTab = _get_editor_for_format(format)
	
	tab_container.add_child(editor)
	tab_container.set_tab_title(tab_container.get_tab_count()-1, editor.get_title())
	tab_container.current_tab = tab_container.get_tab_count()-1
	editor.content = defaults
	if not get_parent() is Viewport:
		editor.editor_window = get_parent()
	else:
		editor.editor_window = self
	editor.connect("contents_changed", self, "on_current_tab_contents_changed")

	return editor
	
func open_new_file_from_path(path: String) -> SugarEditorTab:
	var result = SJSON.from_file(path)
	var tab : SugarEditorTab
	
	if not result.has("error"):
		if result.has("__format"):
			tab = new_empty_file(result.__format)
			tab.path = path
			tab_container.set_tab_title(tab_container.get_tab_count()-1, tab.get_title())
			tab.content = JSON.print(result, "  ")
	return tab
	
func on_current_tab_contents_changed():
	var new_title : String = tab_container.get_current_tab_control().get_title() + " *"
	tab_container.set_tab_title(tab_container.current_tab, new_title)
	tab_container.update()
	
func on_new_file_button_pressed():
	var format := new_format_option_button.get_selected_metadata() as String
	new_empty_file(format)
	new_file_dialog.visible = false
	
func on_help_pressed(id: int) -> void:
	match id:
		HELP_MENU_OPTIONS.ABOUT:
			$AboutDialog.popup_centered()
	
func on_option_pressed(id: int) -> void:
	
	match id:
		FILE_MENU_OPTIONS.OPEN_FILE:
			file_dialog.add_filter("*.json; Archivos de configuración")

			file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
			
			file_dialog.popup_exclusive = true
			file_dialog.popup_centered_ratio()
			file_dialog.connect("file_selected", self, "on_open_file_file_selected")
		FILE_MENU_OPTIONS.OPEN_CHARACTER:
			character_dialog.popup_centered_ratio(0.25)
		FILE_MENU_OPTIONS.CHECK_FILE:
			validate_current_file()
		FILE_MENU_OPTIONS.NEW_FILE:
			new_file_dialog.popup_centered()
		FILE_MENU_OPTIONS.SAVE_FILE:
			var current_tab = tab_container.get_current_tab_control()
			if current_tab.path:
				save_current_file()
			else:
				save_current_file_as()
		FILE_MENU_OPTIONS.SAVE_FILE_AS:
			save_current_file_as()

func validate_current_file() -> bool:
	var tab_control = tab_container.get_current_tab_control()
	var validation_result : bool = SJSON.validate_string(tab_control.content) as bool
	if validation_result:
		code_validation_status_label.text = "Code is valid"
	else:
		code_validation_status_label.text = "Code is invalid"
	return validation_result

func save_current_file():
	var file := File.new()
	var path := tab_container.get_current_tab_control().path as String
	if validate_current_file():
		file.open(path, File.WRITE)
		file.store_string(tab_container.get_current_tab_control().content)
		file.close()
		tab_container.set_tab_title(tab_container.current_tab, tab_container.get_current_tab_control().get_title())
		tab_container.update()
	for auto_reload_path in AUTO_RELOAD_PATHS:
		if auto_reload_path in path:
			GameManager.reload_game()
			break
func _on_character_selected(character):
	open_new_file_from_path("res://game/characters/%s.json" % character)
	
func save_current_file_as():

	save_file_dialog.add_filter("*.json; Archivos de configuración")

	save_file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
	
	save_file_dialog.popup_exclusive = true
	save_file_dialog.popup_centered_ratio()
	save_file_dialog.connect("file_selected", self, "on_save_current_file_as")
	
func on_save_current_file_as(path):
	tab_container.get_current_tab_control().path = path
	save_current_file()

# Called when a user opens a file
func on_open_file_file_selected(file_path: String):
	open_new_file_from_path(file_path)
func _ready():
	ui_setup()