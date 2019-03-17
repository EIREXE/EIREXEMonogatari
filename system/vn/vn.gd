extends Control

"""
Visual novel game
"""

const TEXT_SPEED = 15.0

onready var text_label = get_node("Panel/StoryContainer/VBoxContainer/TextLabel")
onready var background = get_node("Panel/Background")
onready var character_label = get_node("Panel/StoryContainer/CharacterNameTextureRect/CharacterLabel")
onready var character_texture_rect = get_node("Panel/StoryContainer/CharacterNameTextureRect")
var current_position = 0.0
var current_line = 0
var lines : Array = []

func run_scene(scene: Dictionary) -> void:
	set_process(false)
	lines = scene.lines
	current_line = 0
	_continue_parsing()

func _get_character_speed(character):
	if character == ",":
		return 7.0
	else:
		return TEXT_SPEED

# Returns the current line's target text, and also applies settings such as auto_quote
func _get_current_line_text():
	var target_text = lines[current_line].text
	if GameManager.game_info.auto_quote:
		target_text = "\"%s\"" % target_text
	return target_text

func change_background(background_filename: String):
	background.texture = ImageTexture.new()
	background.texture.load("res://game/backgrounds/" + background_filename)

# Executes a non-text line
func _run_nontext_line(line):
	match line.__format:
		"background_change_line":
			change_background(line.background)

# Runs all nodes
func _continue_parsing():
	for line_i in range(current_line, lines.size(), 1):
		current_line = line_i

		if lines[line_i].__format == "text_line":
			current_position = 0
			set_process(true)
			text_label.text = ""
			if lines[line_i].character == "":
				character_texture_rect.visible = false
			else:
				character_texture_rect.visible = true
				character_label.text = GameManager.characters[lines[line_i].character].name
			break
		else:
			_run_nontext_line(lines[line_i])
func _process(delta):
	var target_text = _get_current_line_text()
	
	if current_position < target_text.length():
		current_position += _get_character_speed(target_text.substr(current_position-1, 1))*delta
	else:
		current_position = target_text.length()
		set_process(false)
	text_label.text = target_text.substr(0, current_position)

func _unhandled_input(event):
	# text skipping
	if event.is_action_pressed("skip_text") and not event.is_echo():
			if _get_current_line_text().length() == text_label.text.length():
				if current_line != lines.size()-1:
					if current_line + 1 < lines.size():
						current_line += 1
					_continue_parsing()
			else:
				current_position = _get_current_line_text().length()
			
func _ready():
	set_process(false)