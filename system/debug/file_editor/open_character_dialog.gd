extends AcceptDialog

signal character_selected(character)

var character_list := ItemList.new()

func _ready():
	add_child(character_list)
	character_list.connect("item_selected", self, "_on_item_selected")
	character_list.connect("nothing_selected", self, "_on_item_selected")
	connect("confirmed", self, "_on_confirm")
	
	for i in GameManager.game.characters:
		var character = GameManager.game.characters[i]
		character_list.add_item(character.name)
		character_list.set_item_metadata(character_list.get_item_count()-1, i)

	add_cancel(tr("EDITOR_CANCEL"))

	_on_nothing_selected()
func _on_confirm():
	var selected_items = character_list.get_selected_items()
	if selected_items.size() > 0:
		var idx = selected_items[0]
		emit_signal("character_selected", character_list.get_item_metadata(idx))
		
func _on_item_selected(idx):
	get_ok().disabled = false
func _on_nothing_selected():
	get_ok().disabled = true