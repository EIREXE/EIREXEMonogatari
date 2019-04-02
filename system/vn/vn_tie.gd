extends TextureRect
"""
VN Text Interface Engine (TIE)
"""
signal line_skipped

const TEXT_SPEED = 15.0 # TODO: Make this user adjustable?

onready var text_label = get_node("VBoxContainer/TextLabel")
onready var character_name_texture_rect = get_node("CharacterNameTextureRect")
onready var character_label = get_node("CharacterNameTextureRect/CharacterLabel")

var _target_text = ""
var _current_text = ""
var _current_position = 0

var game

# Some characters such as commas have different speeds, in order to create what
# looks like natural speech.
func _get_character_speed(character):
	var speed = TEXT_SPEED
	match character:
		"," or ";":
			speed = TEXT_SPEED*0.5
		".":
			speed = TEXT_SPEED * 0.25
	return speed
	
func _ready():
	set_process(false)
	
func _process(delta: float):
	# Text interface engine shenanigans
	
	if _current_position < _target_text.length():
		_current_position += _get_character_speed(_target_text.substr(_current_position-1, 1))*delta
	else:
		_current_position = _target_text.length()
		set_process(false)
	text_label.text = _target_text.substr(0, _current_position)
	
func _unhandled_input(event: InputEvent):
	# text skipping
	if event.is_action_pressed("skip_text") and not event.is_echo():
		if _target_text.length() == text_label.text.length():
			emit_signal("line_skipped")
		else:
			_current_position = _target_text.length()
			
func show_text(text: String, character: String = ""):
	_target_text = text
	_current_text = ""
	text_label.text = ""
	_current_position = 0
	
	if character == "":
		character_name_texture_rect.visible = false
	else:
		character_name_texture_rect.visible = true
		character_label.text = game.characters[character].name
		
	set_process(true)