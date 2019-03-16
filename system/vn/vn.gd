extends Control

const TEXT_SPEED = 15.0
var current_position = 0.0
var current_line = 0
var lines : Array = []

onready var text_label = get_node("Panel/StoryContainer/VBoxContainer/TextLabel")
onready var background = get_node("Panel/Background")
onready var character_label = get_node("Panel/StoryContainer/TextureRect/CharacterLabel")
func run_scene(scene):
	set_process(false)
	lines = scene.lines
	current_line = 0
	parse_until_text()

func get_character_speed(character):
	if character == ",":
		return 7.0
	else:
		return TEXT_SPEED

func get_current_line_text():
	var target_text = lines[current_line].text
	if GameManager.game_info.auto_quote:
		target_text = "\"%s\"" % target_text
	return target_text

func change_background(background_file):
	background.texture = ImageTexture.new()
	background.texture.load("res://game/backgrounds/" + background_file)

func run_nontext_line(line):
	match line.__format:
		"background_change_line":
			change_background(line.background)

func parse_until_text():
	for line_i in range(current_line, lines.size(), 1):
		current_line = line_i

		if lines[line_i].__format == "text_line":
			current_position = 0
			set_process(true)
			text_label.text = ""
			character_label.text = GameManager.characters[lines[line_i].character].name
			break
		else:
			run_nontext_line(lines[line_i])
func _process(delta):
	var target_text = get_current_line_text()
	
	if current_position < target_text.length():
		current_position += get_character_speed(target_text.substr(current_position-1, 1))*delta
	else:
		current_position = target_text.length()
		set_process(false)
	text_label.text = target_text.substr(0, current_position)

func _unhandled_input(event):
	if event.is_action_pressed("skip_text") and not event.is_echo():
		if get_current_line_text().length() == text_label.text.length():
			if current_line + 1 < lines.size():
				current_line += 1
			parse_until_text()
		else:
			current_position = get_current_line_text().length()
			
func _ready():
	set_process(false)