extends MarginContainer

class_name SugarEditorFile


var path : String setget set_path

func set_path(value):
	path = value
	
func get_title() -> String:
	if path:
		return path.split("/")[-1]
	else:
		return tr("Sin Titulo")
		
var content : String setget set_content, get_content

func set_content(value):
	content = value

func get_content():
	return content