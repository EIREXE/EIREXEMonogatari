class_name JSONLoader

func from_file(path: String) -> Dictionary:
	var file := File.new()
	var file_result := file.open(path, File.READ)
	if file_result == OK:
		var text := file.get_as_text()
		var result := JSON.parse(text)
		
		return result.result
	else:
		return {"error": file_result}