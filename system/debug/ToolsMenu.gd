extends WindowDialog

const SugarToolWindow = preload("ToolWindow.gd")

var button_container = VBoxContainer.new()

const TOOLS = [
		{
			"name": "JSON Editor",
			"path": "res://system/debug/file_editor/editor.tscn"
		}
	]

func _ready():
	window_title = "Herramientas de desarrollo"
	add_child(button_container)
	button_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	for tool_info in TOOLS:
		var button := Button.new()
		button.text = tool_info["name"]
		button.connect("button_up", self, "run_tool", [tool_info["path"]])
		button_container.add_child(button)
func run_tool(tool_path: String):
	var scene = load(tool_path)
	var tool_window = SugarToolWindow.new() as WindowDialog
	var tool_instance = scene.instance()
	add_child(tool_window)
	tool_window.add_child(tool_instance)
	tool_window.popup_centered_ratio()
	tool_window.hide()
	tool_window.show()
	
func _input(event):
	if OS.is_debug_build():
		if Input.is_action_just_released("open_debug"):
			get_tree().current_scene.visible = false
			popup_centered_ratio(0.25)