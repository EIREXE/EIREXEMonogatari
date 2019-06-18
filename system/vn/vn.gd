extends Control

"""
Visual novel game
"""

signal scene_finished

onready var background = get_node("Panel/Background")
onready var character_container = get_node("Panel/CharacterContainer")
onready var tie := get_node("Panel/StoryContainer")
# Lines that require waiting instead of being executed at once
const WAIT_LINES = ["text_line"]

var game
var current_line = 0
var lines : Array = []
onready var minigame_container = get_node("Panel/Minigame")
var visible_characters = {}

# Runs a scene from scene data
func run_scene(scene: Dictionary) -> void:
	set_process(false)
	lines = scene.lines
	current_line = 0
	_continue_parsing()

# Gets a state key from a path with the format "characters/nina"
static func get_state_key_from_path(path: String, state: Dictionary):
	var current_key
	for key in path.split('/'):
		if not current_key:
			current_key = state[key]
		else:
			current_key = current_key[key]
	return current_key

# Returns a state print with filters applied, takes the raw state print in the form of path|filter(arguments)
static func parse_state_print_filters(raw_state_print: String, state: Dictionary):
	var regex = RegEx.new()
	regex.compile("(.*)\\|(.*)\\((.*)\\)")
	var result = regex.search(raw_state_print)
	var filtered_text: String = ""
	if not result:
		push_error("Invalid state print: {}".format(raw_state_print))
	else:
		var path = result.get_string(1)
		var filter = result.get_string(2)
		var arguments = result.get_string(3)
		var key = get_state_key_from_path(path, state)
		match filter:
			"caps":
				var singular = arguments.split(",")[0].strip_edges()
				var plural = arguments.split(",")[1].strip_edges()
				if key > 1 or key == 0:
					filtered_text = plural
				else:
					filtered_text = singular

	return filtered_text

static func parse_state_prints(text: String, state: Dictionary) -> String:
	print(state)
	var regex = RegEx.new()
	regex.compile("\\{(.*?)\\}")
	var result_found = true
	while result_found:
		result_found = false
		var result = regex.search(text)
		if result:
			result_found = true
			var start = result.get_start()
			var length = result.get_end()-result.get_start()
			var path := result.get_string(1) as String
			
			var text_to_insert: String
			
			if path.split("|").size() > 1:
				text_to_insert = parse_state_print_filters(path, state)
			else:
				text_to_insert = str(get_state_key_from_path(path, state))
			text.erase(start, length)
			text = text.insert(start, text_to_insert)
	return text
# Allows the text box to print state info
static func process_state_prints(text: String) -> String:
	return parse_state_prints(text, GameManager.game.state)

# Returns the current line's target text in the correct locale, and also applies settings such as auto_quote
func _get_current_line_text():
	var target_text : String
	# We try to get the current line based on the current locale, if this fails
	# we will just try to get it from the fallback locale, if this fails too we
	# will attempt to get the first line we can find, if there are no lines the
	# text will be ### LINE NOT FOUND ###
	if lines[current_line].text.has(TranslationServer.get_locale()):
		target_text = lines[current_line].text[TranslationServer.get_locale()]
	elif lines[current_line].text.has(ProjectSettings.get_setting("locale/fallback")):
		target_text = lines[current_line].text[ProjectSettings.get_setting("locale/fallback")]
	else:
		target_text = "### LINE NOT FOUND ###"
		if lines[current_line].text.size() > 0:
			target_text = lines[current_line].text.values()[0]
		push_error("Line translation not found uwu")
	target_text = process_state_prints(target_text)
	if game.game_info.auto_quote:
		match lines[current_line].line_style:
			"internal_dialogue":
				target_text = "(%s)" % target_text
			_:
				target_text = "\"%s\"" % target_text
	return target_text

# Clears all VN graphics
func clear_all():
	background.texture = null
	for character in visible_characters:
		visible_characters[character].free()
	visible_characters = {}

func change_background(background_filename: String):
	background.texture = load("res://game/backgrounds/" + background_filename)
# Shows a character
func change_character_visibility(line: Dictionary):
	if game.characters.has(line.character):
		var character = game.characters[line.character]
		if visible_characters.has(line.character):
			visible_characters[line.character].queue_free()
			visible_characters.erase(line.character)
		if line.show:
			if character.graphics_layers.has(line.layer):
				var main_node = Control.new()
				main_node.size_flags_horizontal = SIZE_EXPAND_FILL
				for texture_path in character.graphics_layers[line.layer].graphics:
					var path = "res://game/characters/%s/%s" % [line.character, texture_path]
					var texture_rect := TextureRect.new()
					texture_rect.expand = true
					texture_rect.texture = load(path)
					texture_rect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
					texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL

					main_node.add_child(texture_rect)
				character_container.add_child(main_node)
				visible_characters[line.character] = main_node
			else:
				push_error("Character %s doesn't have graphics layer %s" % [line.character, line.layer])
	else:
		push_error("Character %s not found" % line.character)

func show_current_line_text():
	tie.show_text(_get_current_line_text(), lines[current_line].character, lines[current_line].line_style)

func run_minigame(line: Dictionary):
	var minigame
	if line.path.ends_with(".gd"):
		minigame = load(line.path).new()
	else:
		minigame = load(line.path).instance()
		
	game.run_minigame(minigame, line.path)
# Executes a non-text line
func _execute_line(line):
	match line.__format:
		"text_line":
			show_current_line_text()
		"background_change_line":
			change_background(line.background)
		"change_character_visibility_line":
			change_character_visibility(line)
		"run_minigame_line":
			run_minigame(line)

func fast_forward_to_line(line: int):
	# TODO
	pass

# Continues parsing lines
func _continue_parsing():

	print("from " + str(current_line) + " to " + str(lines.size()))
	for line_i in range(current_line, lines.size(), 1):
		current_line = line_i
		var format = lines[line_i].__format
		_execute_line(lines[line_i])
		if format in WAIT_LINES:
			break

func _on_text_line_skipped():
	if current_line >= lines.size()-1:
		emit_signal("scene_finished")
	elif current_line != lines.size()-1:
		if current_line + 1 < lines.size():
			current_line += 1
		_continue_parsing()


func _ready():
	set_process(false)
	tie.game = game
	tie.connect("line_skipped", self, "_on_text_line_skipped")