extends Control

onready var tab_container := get_node("Panel/VBoxContainer/TabContainer")
onready var file_button : MenuButton = get_node("Panel/VBoxContainer/HBoxContainer/FileButton")
func ui_setup():
	var vb_container := VBoxContainer.new()
	
	file_button.get_popup().add_child(vb_container)
	file_button.get_popup().size_flags_horizontal = SIZE_EXPAND
	file_button.get_popup().size_flags_vertical = SIZE_EXPAND
	file_button.get_popup().rect_min_size = Vector2(100, 100)
	vb_container.size_flags_vertical = SIZE_EXPAND
	
	vb_container.set_anchors_preset(PRESET_WIDE)
	
	var shortcut = ShortCut.new()
	shortcut.set_name("Abrir...")
	file_button.get_popup().add_shortcut(shortcut)
func _ready():
	ui_setup()
	for key in JSONLoader.formats:
		var format : Dictionary = JSONLoader.formats[key]
		var tree := Tree.new()
		tree.name = format["name"]
		tab_container.add_child(tree)
		if JSONLoader.formats[key].has("keys"):
			for formatKey in JSONLoader.formats[key]["keys"]:
				field2tree(tree, JSONLoader.formats[key]["keys"][formatKey], formatKey)
			
func field2tree(tree : Tree, field : Dictionary, field_name : String, parent : TreeItem = null) -> void:
	var item = tree.create_item(parent)
	item.set_text(0, field_name)
	
	if field["type"] == "Object":
		for key in field["object"]:
			field2tree(tree, field["object"][key], key, item)