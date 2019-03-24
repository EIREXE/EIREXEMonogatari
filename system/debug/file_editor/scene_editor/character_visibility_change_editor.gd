extends "base_line_editor.gd"

var character_selector := OptionButton.new()
var layer_list = ItemList.new()
var visible_check = CheckBox.new()
func _ready():
	extra_buttons_container.add_child(character_selector)
	extra_buttons_container.add_child(visible_check)
	visible_check.text = tr("SCENE_EDITOR_CHARACTER_LAYER_VISIBLE")
	character_selector.connect("item_selected", self, "on_character_selected")
	editable_area.add_child(layer_list)
	
	layer_list.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	layer_list.size_flags_vertical = SIZE_EXPAND_FILL
	load_characters()
	load_layers()
	if line.layer == "" and layer_list.get_item_count() > 0:
		layer_list.select(0)
		on_layer_selected(0)

	editable_area.rect_min_size = Vector2(0, 100)
		
	if line.show == false:
		on_layer_visibility_changed(false)
	else:
		visible_check.pressed = true
	
	visible_check.connect("toggled", self, "on_layer_visibility_changed")
	layer_list.connect("item_selected", self, "on_layer_selected")
		
func on_character_selected(id):
	line.character = character_selector.get_item_metadata(id)
	load_layers()
	.update_line()
	
func on_layer_selected(id):
	line.layer = layer_list.get_item_metadata(id)
	.update_line()
	
func on_layer_visibility_changed(new_value: bool):
	line.show = new_value
	if line.show and layer_list.get_parent() != editable_area:
		editable_area.add_child(layer_list)
		editable_area.rect_min_size = Vector2(0, 100)
	else:
		editable_area.remove_child(layer_list)
		editable_area.rect_min_size = Vector2(0, 0)
	
func load_layers():
	layer_list.clear()
	var character = GameManager.characters[line.character]
	for layer_name in character.graphics_layers:
		layer_list.add_item(character.graphics_layers[layer_name].name)
		layer_list.set_item_metadata(layer_list.get_item_count()-1, layer_name)
		if layer_name == line.layer:
			layer_list.select(layer_list.get_item_count()-1)
func load_characters():
	character_selector.clear()
	for character_name in GameManager.characters:
		var character = GameManager.characters[character_name]
		character_selector.add_item(character.name)
		character_selector.set_item_metadata(character_selector.get_item_count()-1, character_name)
		if character_name == line.character:
			character_selector.select(character_selector.get_item_count()-1)
	if not character_selector.selected:
		character_selector.select(0)
		on_character_selected(0)