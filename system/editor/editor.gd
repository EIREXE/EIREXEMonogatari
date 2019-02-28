extends Control

func _ready():
	for key in JSONLoader.formats:
		var format : Dictionary = JSONLoader.formats[key]
		var tree := Tree.new()
		tree.name = format["name"]
		$Panel/TabContainer.add_child(tree)
		if JSONLoader.formats[key].has("keys"):
			for formatKey in JSONLoader.formats[key]["keys"]:
				field2tree(tree, JSONLoader.formats[key]["keys"][formatKey], formatKey)
			
func field2tree(tree : Tree, field : Dictionary, field_name : String, parent : TreeItem = null) -> void:
	var item = tree.create_item(parent)
	item.set_text(0, field_name)
	
	if field["type"] == "Object":
		for key in field["object"]:
			field2tree(tree, field["object"][key], key, item)