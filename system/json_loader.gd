extends Node

var formats := {}

func _ready():
	load_formats()

func validate(data: Dictionary, format_keys: Dictionary) -> bool:
	var validation_OK := false

	for key in data:
		if format_keys.has(key):
			var keyData : Dictionary = format_keys[key]

			match keyData.type:
				"Object":
					validation_OK = validate(data[key], keyData["object"])
				"Number":
					validation_OK = typeof(data[key]) == TYPE_ARRAY or TYPE_INT
				"Boolean":
					validation_OK = typeof(data[key]) == TYPE_BOOL
		if validation_OK == false:
			break
	return validation_OK

func validate_format(data: Dictionary, format_name: String) -> bool:
	var format : Dictionary = formats[data['__format']]["keys"]
	
	return validate(data, format)

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
		if result.result.has("__format"):
			if validate_format(result.result, result.result["__format"]):
				return result.result
	return {"error": file_result}
	
func get_defaults(format_keys: Dictionary):
	var result = {}
	for key in format_keys:
		var format_key = format_keys[key]
		if format_key.has("default"):
			result[key] = format_key["default"]
		elif format_key["type"] == "Object":
			result[key] = get_defaults(format_key["object"])
	return result
	
func get_format_defaults(format_name: String) -> Dictionary:
	var result : Dictionary
	if formats.has(format_name):
		var format = formats[format_name]
		result = get_defaults(format["keys"])
	result["__format"] = format_name
	return result