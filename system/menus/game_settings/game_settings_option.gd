tool

extends HBoxContainer

enum EDIT_TYPE {
	TYPE_BOOL,
	TYPE_INT
}

export(EDIT_TYPE) var edit_type setget set_edit_type
export(String) var user_settings_key_name 
export(String) var option_name setget set_option_name
export(String) var option_description setget set_option_description
var value setget set_value

export(float) var slider_min
export(float) var slider_max
export(float) var slider_step


onready var option_name_label = get_node("VBoxContainer/OptionName")
onready var option_description_label = get_node("VBoxContainer/OptionDescription")
onready var editor_container = get_node("EditorContainer/VBoxContainer")

signal value_changed

var _option_editor

func _on_value_changed(_value):
	emit_signal("value_changed", _value)
	
func set_value(_value):
	value = _value
	print("setting value to " + str(value))
	match edit_type:
		EDIT_TYPE.TYPE_BOOL:
			_option_editor.pressed = value
		EDIT_TYPE.TYPE_INT:
			_option_editor.value = value



func _update_option_editor():
	match edit_type:
		EDIT_TYPE.TYPE_BOOL:
			_option_editor = CheckButton.new()
			_option_editor as CheckButton
			_option_editor.connect("toggled", self, "_on_value_changed")
		EDIT_TYPE.TYPE_INT:
			_option_editor = SpinBox.new()
			_option_editor as SpinBox
			_option_editor.min_value = slider_min
			_option_editor.max_value = slider_max
			_option_editor.step = slider_step
			_option_editor.connect("value_changed", self, "_on_value_changed")
	if editor_container:
		for child in editor_container.get_children():
			child.queue_free()
		editor_container.add_child(_option_editor)
	
func _ready():
	_update_option_editor()
	set_option_name(option_name)
	set_option_description(option_description)

func set_option_name(value):
	option_name = value
	if option_name_label:
		option_name_label.text = value
func set_option_description(value):
	option_description = value
	if option_description_label:
		option_description_label.text = value
func set_edit_type(value):
	edit_type = value
	_update_option_editor()