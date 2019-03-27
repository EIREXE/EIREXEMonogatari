extends "base_line_editor.gd"

"""
Editor for VN dialogue lines
"""

var line_text = TextEdit.new()
var character_selector := OptionButton.new()

func load_characters():
	character_selector.clear()
	character_selector.add_item(tr("SCENE_EDITOR_NARRATOR"))
	character_selector.set_item_metadata(0, "")
	for character_name in GameManager.game.characters:
		var character = GameManager.game.characters[character_name]
		character_selector.add_item(character.name)
		character_selector.set_item_metadata(character_selector.get_item_count()-1, character_name)
		if character_name == line.character:
			character_selector.select(character_selector.get_item_count()-1)

func get_line_for_locale(locale: String):
	if not line.text.has(locale):
		line.text[locale] = ""
	return line.text[locale]

func set_text_for_locale(locale: String, text: String):
	line.text[locale] = text
	.update_line()
func _ready():
	scene_editor.connect("locale_override_changed", self, "_on_locale_override_changed")
	scene_editor.connect("line_changed", self, "_on_line_changed")
	editable_area.add_child(line_text)
	line_text.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	editable_area.rect_min_size = Vector2(0, 50)
	line_text.connect("text_changed", self, "on_text_changed")
	line_text.text = get_line_for_locale(scene_editor.locale_override)
	load_characters()
	GameManager.game.connect("game_reloaded", self, "load_characters")
	character_selector.connect("item_selected", self, "on_character_selected")
	extra_buttons_container.add_child(character_selector)
func on_text_changed():
	set_text_for_locale(scene_editor.locale_override, line_text.text)
	
func _on_locale_override_changed():
	line_text.text = get_line_for_locale(scene_editor.locale_override)
	
func on_character_selected(id):
	line.character = character_selector.get_item_metadata(id)
	.update_line()
	
func _on_line_changed(i: int):
	if i == get_position_in_parent():
		var new_text = get_line_for_locale(scene_editor.locale_override)
		if line_text.text != new_text:
			line_text.text = get_line_for_locale(scene_editor.locale_override)