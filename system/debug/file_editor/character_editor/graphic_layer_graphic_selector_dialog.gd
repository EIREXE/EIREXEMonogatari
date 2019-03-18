extends AcceptDialog

signal graphics_selected(graphics)

var graphic_list := ItemList.new()

func _ready():
	add_child(graphic_list)
	graphic_list.select_mode = ItemList.SELECT_MULTI
	window_title = tr("CHARACTER_EDITOR_GRAPHIC_LAYER_EDITOR_TITLE")
	graphic_list.connect("multi_selected", self, "_on_item_selected")
	connect("confirmed", self, "_on_confirm")

	add_cancel(tr("EDITOR_CANCEL"))

	get_ok().disabled = true
func _on_confirm():
	var selected_items = graphic_list.get_selected_items()
	var selected_graphics = []
	for item in selected_items:
		selected_graphics.append(graphic_list.get_item_text(item))
	if selected_items.size() > 0:
		emit_signal("graphics_selected", selected_graphics)
		
func load_character_graphics(character: String):
	graphic_list.clear()
	var dir := Directory.new()
	dir.open("res://game/characters/" + character)
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "jpg" or file_path.get_extension() == "png":
			graphic_list.add_item(file_path)
	dir.list_dir_end()
func select_graphics(graphics: Array) -> void:
	for i in range(graphic_list.get_item_count()):
		var text = graphic_list.get_item_text(i)
		if text in graphics:
			get_ok().disabled = false
			graphic_list.select(i)
func _on_item_selected(items, selected):
	if graphic_list.get_selected_items().size() > 0:
		get_ok().disabled = false
	else:
		get_ok().disabled = true