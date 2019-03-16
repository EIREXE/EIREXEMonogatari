extends "base_line_editor.gd"

var background_selector := OptionButton.new()
var background_preview := TextureRect.new()
func _ready():
	extra_buttons_container.add_child(background_selector)
	editable_area.add_child(background_preview)
	background_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	for background in GameManager.backgrounds:
		background_selector.add_item(background)
	background_selector.connect("item_selected", self, "on_background_changed")
	background_preview.expand = true
	background_preview.set_anchors_and_margins_preset(Control.PRESET_HCENTER_WIDE)
	background_preview.rect_size = Vector2(0,100)
	background_preview.rect_position = Vector2(0,-50)
	editable_area.rect_min_size = Vector2(0, 100)
	on_background_changed()
func on_background_changed():
	line.background = background_selector.get_item_text(background_selector.selected)
	background_preview.texture = ImageTexture.new()
	background_preview.texture.load("res://game/backgrounds/" + line.background)
	.update_line()