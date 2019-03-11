extends Control

onready var tab_container : TabContainer = get_node("Panel/VBoxContainer/TabContainer")
onready var file_button : MenuButton = get_node("Panel/VBoxContainer/HBoxContainer/FileButton")
onready var code_validation_status_label = get_node("Panel/VBoxContainer/StatusBar/ValidationStatusLabel")
onready var new_format_option_button = get_node("NewFileDialog/HBoxContainer/OptionButton")
onready var new_file_dialog : WindowDialog = get_node("NewFileDialog")
onready var new_file_button : Button = get_node("NewFileDialog/HBoxContainer/NewFileButton")
enum FILE_MENU_OPTIONS {
	NEW_FILE
	OPEN_FILE,
	CHECK_FILE
}

var open_files := []

func ui_setup():
	var vb_container := VBoxContainer.new()
	vb_container.size_flags_vertical = SIZE_EXPAND
	
	vb_container.set_anchors_preset(PRESET_WIDE)
	
	var new_file_shortcut = ShortCut.new()
	new_file_shortcut.set_name(tr("Nuevo..."))
	file_button.get_popup().add_shortcut(new_file_shortcut, FILE_MENU_OPTIONS.NEW_FILE)
	
	var open_file_shortcut = ShortCut.new()
	open_file_shortcut.set_name(tr("Abrir..."))
	file_button.get_popup().add_shortcut(open_file_shortcut, FILE_MENU_OPTIONS.OPEN_FILE)

	
	var check_file_shortcut = ShortCut.new()
	check_file_shortcut.set_name(tr("Comprobar fichero"))
	file_button.get_popup().add_shortcut(check_file_shortcut, FILE_MENU_OPTIONS.CHECK_FILE)

	
	for key in SJSON.formats:
		var format : Dictionary = SJSON.formats[key]
		new_format_option_button.add_item(format["name"])
		new_format_option_button.set_item_metadata(new_format_option_button.get_item_count()-1, format)
	file_button.get_popup().connect("id_pressed", self, "on_option_pressed")
	new_file_button.connect("pressed", self, "on_new_file_button_pressed")
		
func on_new_file_button_pressed():
	var editor_tab := SugarEditorTab.new()
	var format := new_format_option_button.get_selected_metadata() as Dictionary
	tab_container.add_child(editor_tab)
	editor_tab.content = JSON.print(SJSON.get_defaults(format["keys"]), "  ")
	tab_container.set_tab_title(tab_container.get_tab_count()-1, tr("Sin Titulo"))
	new_file_dialog.visible = false
	
func on_option_pressed(id: int) -> void:
	
	match id:
		FILE_MENU_OPTIONS.OPEN_FILE:
			var file_dialog := FileDialog.new()
			file_dialog.add_filter("*.json; Archivos de configuración")

			file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
			
			add_child(file_dialog)
			file_dialog.popup_exclusive = true
			file_dialog.popup_centered_ratio()
			file_dialog.connect("file_selected", self, "on_open_file_file_selected")
		FILE_MENU_OPTIONS.CHECK_FILE:
			var tab_control = tab_container.get_current_tab_control()
			var validation_result : bool = SJSON.validate_string(tab_control.content) as bool
			if validation_result:
				code_validation_status_label.text = "Code is valid"
			else:
				code_validation_status_label.text = "Code is invalid"
		FILE_MENU_OPTIONS.NEW_FILE:
			new_file_dialog.popup_centered()
	
	
# Called when a user opens a file
func on_open_file_file_selected(file_path: String):
	var editor_tab := SugarEditorTab.new()
	tab_container.add_child(editor_tab)
	editor_tab.path = file_path
	tab_container.set_tab_title(tab_container.get_tab_count()-1, file_path.split("/")[-1])
func _ready():
	ui_setup()
			
func field2tree(tree : Tree, field : Dictionary, field_name : String, parent : TreeItem = null) -> void:
	var item = tree.create_item(parent)
	item.set_text(0, field_name)
	
	if field["type"] == "Object":
		for key in field["object"]:
			field2tree(tree, field["object"][key], key, item)