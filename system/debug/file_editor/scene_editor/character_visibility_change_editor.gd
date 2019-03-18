extends "base_line_editor.gd"

var character_selector := OptionButton.new()
var background_preview := TextureRect.new()
func _ready():
	extra_buttons_container.add_child(character_selector)
	editable_area.add_child(background_preview)
	editable_area.rect_min_size = Vector2(0, 100)
	
	
	
	background_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_preview.expand = true
	background_preview.set_anchors_and_margins_preset(Control.PRESET_HCENTER_WIDE)
	background_preview.rect_size = Vector2(0,100)
	background_preview.rect_position = Vector2(0,-50)
	load_characters()
	
func load_characters():
	character_selector.clear()
	character_selector.add_item(tr("SCENE_EDITOR_NARRATOR"))
	character_selector.set_item_metadata(0, "")
	for character_name in GameManager.characters:
		var character = GameManager.characters[character_name]
		character_selector.add_item(character.name)
		character_selector.set_item_metadata(character_selector.get_item_count()-1, character_name)
		if character_name == line.character:
			character_selector.select(character_selector.get_item_count()-1)