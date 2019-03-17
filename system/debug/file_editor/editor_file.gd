extends MarginContainer

"""
Base class for all different JSON file editors
"""

class_name SugarEditorTab

var path : String setget set_path

var content : String setget set_content, get_content

func set_path(value):
	path = value
	
func get_title() -> String:
	if path:
		return path.split("/")[-1]
	else:
		return tr("Sin Titulo")
func set_content(value):
	content = value

func get_content():
	return content