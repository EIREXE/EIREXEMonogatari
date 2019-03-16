extends "base_line_editor.gd"

var line_text = TextEdit.new()
var character_selector := OptionButton.new()
func _ready():
	editable_area.add_child(line_text)
	line_text.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	rect_min_size = Vector2(0, 100)
	line_text.connect("text_changed", self, "on_text_changed")
	
	character_selector.add_item(tr("CHARACTER_NARRATOR"))
	character_selector.set_item_metadata(0, "")
	
	for character_name in GameManager.characters:
		var character = GameManager.characters[character_name]
		character_selector.add_item(character.name)
		character_selector.set_item_metadata(character_selector.get_item_count()-1, character_name)
	character_selector.connect("item_selected", self, "on_character_selected")	
	extra_buttons_container.add_child(character_selector)
	
	on_character_selected(0)
func on_text_changed():
	line.text = line_text.text
	.update_line()
	
func on_character_selected(id):
	line.character = character_selector.get_item_metadata(id)
	.update_line()