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
		set_size(Vector2())
	
func set_label_text(value):
	label_text = value
	if container:
		label.rect_size.x = 0
		container.rect_size.x = 0
		label.text = value
		set_size(Vector2())

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "set_size")
	set_size(Vector2())


func set_size(size: Vector2):
	if container:


		container.rect_size = Vector2(label.rect_size.x, container.rect_size.y)
		rect_min_size = Vector2()
		rect_size.x = 0

		rect_min_size = Vector2(container.rect_size.x + rect_size.x, 20)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Label_item_rect_changed():
	set_size(Vector2())