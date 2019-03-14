extends Control

onready var tab_container : TabContainer = get_node("Panel/VBoxContainer/TabContainer")
onready var file_button : MenuButton = get_node("Panel/VBoxContainer/HBoxContainer/FileButton")
onready var code_validation_status_label = get_node("Panel/VBoxContainer/StatusBar/ValidationStatusLabel")
onready var new_format_option_button = get_node("NewFileDialog/HBoxContainer/OptionButton")
onready var new_file_dialog : WindowDialog = get_node("NewFileDialog")
onready var new_file_button : Button = get_node("NewFileDialog/HBoxContainer/NewFileButton")

const SugarJSONEditorTab = preload("res://system/debug/file_editor/editor_json_file.gd")
const SugarSceneEditorTab = preload("res://system/debug/file_editor/scene_editor/scene_editor.gd")
enum FILE_MENU_OPTIONS {
	NEW_FILE,
	OPEN_FILE,
	SAVE_FILE,
	SAVE_FILE_AS,
	CHECK_FILE
}
var file_dialog := FileDialog.new()
var save_file_dialog := FileDialog.new()
var open_files := []

func ui_setup():
	add_child(file_dialog)
	add_child(save_file_dialog)
	
	var vb_container := VBoxContainer.new()
	vb_container.size_flags_vertical = SIZE_EXPAND
	
	vb_container.set_anchors_preset(PRESET_WIDE)
	
	var new_file_shortcut = ShortCut.new()
	new_file_shortcut.set_name(tr("Nuevo..."))
	file_button.get_popup().add_shortcut(new_file_shortcut, FILE_MENU_OPTIONS.NEW_FILE)
	
	var open_file_shortcut = ShortCut.new()
	open_file_shortcut.set_name(tr("Abrir..."))
	file_button.get_popup().add_shortcut(open_file_shortcut, FILE_MENU_OPTIONS.OPEN_FILE)

	var save_file_shortcut = ShortCut.new()
	save_file_shortcut.set_name(tr("Guardar"))
	file_button.get_popup().add_shortcut(save_file_shortcut, FILE_MENU_OPTIONS.SAVE_FILE)
	
	var save_as_shortcut = ShortCut.new()
	save_as_shortcut.set_name(tr("Guardar como..."))
	file_button.get_popup().add_shortcut(save_as_shortcut, FILE_MENU_OPTIONS.SAVE_FILE_AS)
	
	file_button.get_popup().add_separator()
	
	var check_file_shortcut = ShortCut.new()
	check_file_shortcut.set_name(tr("Comprobar fichero"))
	file_button.get_popup().add_shortcut(check_file_shortcut, FILE_MENU_OPTIONS.CHECK_FILE)

	
	for key in SJSON.formats:
		var format : Dictionary = SJSON.formats[key]
		new_format_option_button.add_item(format["name"])
		new_format_option_button.set_item_metadata(new_format_option_button.get_item_count() - 1, key)
	file_button.get_popup().connect("id_pressed", self, "on_option_pressed")
	new_file_button.connect("pressed", self, "on_new_file_button_pressed")
		
func new_file(contents = null, path = null, type = null):
	var editor_tab
	if type == "scene":
		editor_tab = SugarSceneEditorTab.new()
	else:
		editor_tab = SugarJSONEditorTab.new()
	tab_container.add_child(editor_tab)
	if path:
		editor_tab.load_from_path(path)
	tab_container.set_tab_title(tab_container.get_tab_count()-1, editor_tab.get_title())
	if contents:
		editor_tab.content = contents
	
	editor_tab.connect("contents_changed", self, "on_current_tab_contents_changed")
		
	return editor_tab
	
func on_current_tab_contents_changed():
	var new_title : String = tab_container.get_current_tab_control().get_title() + " *"
	tab_container.set_tab_title(tab_container.current_tab, new_title)
	tab_container.update()
	
func on_new_file_button_pressed():
	var format := new_format_option_button.get_selected_metadata() as String
	new_file(JSON.print(SJSON.get_format_defaults(format), "  "), null, format)
	new_file_dialog.visible = false
	
func on_option_pressed(id: int) -> void:
	
	match id:
		FILE_MENU_OPTIONS.OPEN_FILE:
			file_dialog.add_filter("*.json; Archivos de configuración")

			file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
			
			file_dialog.popup_exclusive = true
			file_dialog.popup_centered_ratio()
			file_dialog.connect("file_selected", self, "on_open_file_file_selected")
		FILE_MENU_OPTIONS.CHECK_FILE:
			check_current_file()
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
		

func check_current_file() -> bool:
	var tab_control = tab_container.get_current_tab_control()
	var validation_result : bool = SJSON.validate_string(tab_control.content) as bool
	if validation_result:
		code_validation_status_label.text = "Code is valid"
	else:
		code_validation_status_label.text = "Code is invalid"
	return validation_result

func save_current_file():
	var file = File.new()
	if check_current_file():
		file.open(tab_container.get_current_tab_control().path, File.WRITE)
		file.store_string(tab_container.get_current_tab_control().content)
		file.close()
		tab_container.set_tab_title(tab_container.current_tab, tab_container.get_current_tab_control().get_title())
		tab_container.update()
	
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
	new_file(null, file_path)
func _ready():
	ui_setup()

func field2tree(tree : Tree, field : Dictionary, field_name : String, parent : TreeItem = null) -> void:
	var item = tree.create_item(parent)
	item.set_text(0, field_name)
	
	if field["type"] == "Object":
		for key in field["object"]:
			field2tree(tree, field["object"][key], key, item)