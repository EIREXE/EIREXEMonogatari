tool
extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var label = get_node("CenterContainer/Label")

onready var container = get_node("CenterContainer")

export(String) var button_text setget set_button_text
export(String) var label_text setget set_label_text
func set_button_text(value):
	button_text = value
	if container:
		text = value
		rect_size.x = 0
		on_size_changed()
	
func set_label_text(value):
	label_text = value
	if container:
		label.text = value
		label.rect_size.x = 0
		container.rect_size.x = 0
		on_size_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "on_size_changed")
	on_size_changed()
	set_label_text(label_text)
	set_button_text(label_text)


func on_size_changed():
	if container:


		container.rect_size = Vector2(label.rect_size.x, container.rect_size.y)
		rect_min_size = Vector2()
		rect_size.x = 0

		rect_min_size = Vector2(container.rect_size.x + rect_size.x, 20)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Label_item_rect_changed():
	pass
	#on_size_changed()
