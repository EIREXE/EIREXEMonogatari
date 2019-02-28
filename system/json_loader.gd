extends Node

var formats := {}

func _ready():
	load_formats()

func validate(data: Dictionary) -> bool:
	var validation_OK := false
	if data.has('__format'):
		var format : Dictionary = formats[data['__format']]
		for key in data:
			if format["keys"].has(key):
				var keyData : Dictionary = data["keys"]["key"]
				
				match keyData.type:
					"Object":
						validation_OK = validate(data[key])
					"Number":
						validation_OK = typeof(data[key]) == TYPE_ARRAY or TYPE_INT
					"Boolean":
						validation_OK = typeof(data[key]) == TYPE_BOOL
			if validation_OK == false:
				break
	return validation_OK

func load_formats():
	var dir := Directory.new()
	dir.open("res://system/validation")
	dir.list_dir_begin()
	while true:
		var file_path := dir.get_next()
		if file_path == "":
			break
		elif not file_path.begins_with(".") and file_path.get_extension() == "json":
			var file := File.new()
			var file_result := file.open("res://system/validation/" + file_path, File.READ)
			if file_result == OK:
				var text := file.get_as_text()
				var result := JSON.parse(text)
				if result.error == OK:
					formats[file_path.get_basename()] = result.result
				else:
					pass
			else:
				pass
	dir.list_dir_end()
	
func from_file(path: String) -> Dictionary:
	var file := File.new()
	var file_result := file.open(path, File.READ)
	if file_result == OK:
		var text := file.get_as_text()
		var result := JSON.parse(text)
		if validate(result.result):
			return result.result
	return {"error": file_result}