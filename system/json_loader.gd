extends Node

"""
Universal loader and validator for JSON files, uses files from res://system/validation
"""

var formats := {}

func _ready():
	load_formats()

# Ensures the key complies with the information in keyData
func validate_key(value, keyData: Dictionary) -> bool:
	var validation_OK := false
	match keyData.type:
		"Object":
			validation_OK = validate(value, keyData.object)
		"ObjectOf":
			for i in value:
				var object = value[i]
				validation_OK = validate_key(object, keyData.objectType)
				if not validation_OK:
					break
		"Number":
			validation_OK = typeof(value) == TYPE_REAL
		"Boolean":
			validation_OK = typeof(value) == TYPE_BOOL
		"String":
			validation_OK = typeof(value) == TYPE_STRING
		"Array":
			var array_type = keyData.arrayType
			print("checking array entry %s" % keyData.arrayType)
			validation_OK = typeof(value) == TYPE_ARRAY
			for entry in value:

				validation_OK = validate_key(entry, array_type)
				if not validation_OK:
					break
		"Format":
			if formats.has(keyData.format):
				validation_OK = validate(value, formats[keyData.format]["keys"])
	return validation_OK

# Validates a dictionary against a group of format keys
func validate(data: Dictionary, format_keys: Dictionary) -> bool:
	var validation_OK := false

	for key in data:
		if format_keys.has(key):
			var keyData : Dictionary = format_keys[key]
			validation_OK = validate_key(data[key], keyData)
		else:
			validation_OK = true
		if validation_OK == false:
			print("Validation failed for key %s" % [key])
			break
	return validation_OK

# Validates a dictionary, automatically gets the proper key data
func validate_dict(data: Dictionary) -> bool:
	if data.has("__format"):
		var format : Dictionary = formats[data['__format']]["keys"]
		return validate(data, format)
	else:
		return true

# Validates a file from string
func validate_string(string: String) -> bool:
	var result := JSON.parse(string)
	if result.error == OK:
		return validate_dict(result.result)
	else:
		return false

# Loads all the format data from the validation folder
func load_formats():
	var dir := Directory.new()
	if dir.open("res://system/validation") == OK:
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
	
# Loads and validates a JSON file from the disk, returns the file
func from_file(path: String, validation: bool = true) -> Dictionary:
	var file := File.new()
	var file_result := file.open(path, File.READ)
	var json_output : Dictionary
	if file_result == OK:
		var text := file.get_as_text()
		var result := JSON.parse(text)
		if result.error == OK:
			return result.result
			var validation_result := validate_dict(result.result)
			if validation_result:
				json_output = result.result
	else:
		json_output = {"error": file_result}
	return json_output
	
	
# Gets the defaults (a "skeleton") of a dictionary of format keys.
func get_defaults(format_keys: Dictionary):
	var result = {}
	for key in format_keys:
		var format_key = format_keys[key]
		if format_key.has("default"):
			result[key] = format_key.default
		elif format_key["type"] == "ObjectOf":
			result[key] = {}
		elif format_key["type"] == "Object":
			result[key] = get_defaults(format_key["object"])
		elif format_key["type"] == "String":
			result[key] = ""
		elif format_key["type"] == "Number":
			result[key] = 0
		elif format_key["type"] == "Array":
			result[key] = []
	return result

# Gets the defaults for a format by name
func get_format_defaults(format_name: String) -> Dictionary:
	var result : Dictionary
	if formats.has(format_name):
		var format = formats[format_name]
		result = get_defaults(format["keys"])
	result["__format"] = format_name
	return result