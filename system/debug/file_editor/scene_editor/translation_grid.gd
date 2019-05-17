extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var lines

signal line_changed

func set_grid(l: Array):
	
	lines = l
	
	for child in get_children():
		child.queue_free()
		
	# Add language label
	
	var language_container = HBoxContainer.new()
	
	var character_header_label := Label.new()
	character_header_label.text = tr("TRANSLATION_GRID_CHARACTER")
	#character_header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_header_label.align = ALIGN_CENTER
	language_container.add_child(character_header_label)
	for locale in GameManager.game.game_info.supported_languages:
		var label = Label.new()
		label.text = TranslationServer.get_locale_name(locale)
		label.align = ALIGN_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		language_container.add_child(label)
	
	add_child(language_container)
		
	for i in range(lines.size()):
		var line = lines[i]
		if line.__format == "text_line":
			var line_hbox := HBoxContainer.new()
			add_child(line_hbox)
			
			var character_label = Label.new()
			#character_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			character_label.text = tr("SCENE_EDITOR_NARRATOR")
			character_label.align = ALIGN_CENTER
			if line.character != "":
				character_label.text = GameManager.game.characters[line.character].name
				
			line_hbox.add_child(character_label)
			
			for locale in GameManager.game.game_info.supported_languages:
				var line_edit := LineEdit.new()
				line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line_hbox.add_child(line_edit)
				line_edit.connect("text_changed", self, "_on_line_edited", [i, locale])
				if line.text.has(locale):
					line_edit.text = line.text[locale]
					
func _on_line_edited(new_text, line_n, locale):
	lines[line_n].text[locale] = new_text
	emit_signal("line_changed", line_n, lines[line_n])