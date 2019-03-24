extends WindowDialog

"""
Development tools menu, opened with F10
"""

const SugarToolWindow = preload("ToolWindow.gd")

var button_container = VBoxContainer.new()

var TOOLS = [
		{
			"name": tr("TOOLS_WINDOW_JSON_EDITOR"),
			"path": "res://system/debug/file_editor/editor.tscn"
		}
	]

var open_tools = {
	
	}

# Generic text scrolling dialog

var scrolling_text_dialog := WindowDialog.new()
var scrolling_text_dialog_label := RichTextLabel.new()
func _ready():
	window_title = tr("TOOLS_WINDOW_TITLE")
	add_child(button_container)
	button_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	for tool_info in TOOLS:
		var button := Button.new()
		button.text = tool_info["name"]
		button.connect("button_up", self, "_run_tool", [tool_info["path"]])
		button_container.add_child(button)
	
	button_container.add_child(HSeparator.new())
	
	var run_main_button = Button.new()
	run_main_button.text = tr("TOOLS_WINDOW_RUN_MAIN_SCENE")
	run_main_button.connect("button_down", GameManager, "run_vn_scene_from_file", ["res://game/scenes/main.json"])
	run_main_button.connect("button_down", self, "hide")
	button_container.add_child(run_main_button)
	
	var game_reload_button = Button.new()
	game_reload_button.text = tr("TOOLS_WINDOW_RELOAD_GAME")
	game_reload_button.connect("button_down", GameManager, "reload_game")
	game_reload_button.connect("button_down", self, "hide")
	button_container.add_child(game_reload_button)
	
	var translation_report_button = Button.new()
	translation_report_button.text = tr("TOOLS_WINDOW_TRANSLATION_REPORT")
	translation_report_button.connect("button_down", self, "get_translation_report")
	button_container.add_child(translation_report_button)
	
	# Setup scrolling text container
	var scroll_container = ScrollContainer.new()
	add_child(scrolling_text_dialog)
	scroll_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	scrolling_text_dialog_label.size_flags_horizontal = SIZE_EXPAND_FILL
	scrolling_text_dialog_label.size_flags_vertical = SIZE_EXPAND_FILL
	scrolling_text_dialog.add_child(scroll_container)
	scroll_container.add_child(scrolling_text_dialog_label)
	
func _run_tool(tool_path: String) -> void:
	if open_tools.has(tool_path):
		open_tools[tool_path].show()
	else:
		var scene = load(tool_path)
		var tool_window = SugarToolWindow.new() as WindowDialog
		var tool_instance = scene.instance()
		add_child(tool_window)
		tool_window.add_child(tool_instance)
		# HACK to prevent window from being hidden when clicked away, while still making use of popup_centered_ratio
		tool_window.popup_centered_ratio()
		tool_window.hide()
		tool_window.show()
		open_tools[tool_path] = tool_window
	
func get_translation_report():
	var dir := Directory.new()
	dir.open("res://game/scenes")
	dir.list_dir_begin()
	var scenes = []
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "json":
			var file := File.new()
			var file_result := file.open("res://game/scenes/" + file_path, File.READ)
			if file_result == OK:
				var text := file.get_as_text()
				var result := JSON.parse(text)
				if result.error == OK:
					result.result["__path"] = file_path
					scenes.append(result.result)
				else:
					pass
			else:
				pass
	dir.list_dir_end()
	var report = ""
	for scene in scenes:
		var locale_untranslated := {}
		for line in scene.lines:
			if line.__format == "text_line":
				for locale in GameManager.game_info.supported_languages:
					var is_translated = true
					if not line.text.has(locale):
						is_translated = false
					elif line.text[locale] == "":
						is_translated = false
					if not is_translated:
						if locale_untranslated.has(locale):
							locale_untranslated[locale] += 1
						else:
							locale_untranslated[locale] = 1
		if locale_untranslated.size() > 0:
			var report_text = tr("TOOLS_WINDOW_TRANSLATION_REPORT_TEXT").format({"path": scene.__path})
			var line_text = ""
			for locale in locale_untranslated: 
				line_text += tr("TOOLS_WINDOW_TRANSLATION_REPORT_LINE_TEXT").format({"n": locale_untranslated[locale], "locale": TranslationServer.get_locale_name(locale)})
				line_text += "\n"
			report += "%s\n%s\n" % [report_text, line_text]
	scrolling_text_dialog_label.text = report
	scrolling_text_dialog.window_title = tr("TOOLS_WINDOW_TRANSLATION_REPORT")
	scrolling_text_dialog.popup_centered_ratio(0.25)
	
func show_menu():
	var size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, size)
	popup_centered_ratio(0.25)
	
func _input(event):
	if OS.is_debug_build():
		if Input.is_action_just_released("open_debug"):
			show_menu()