extends Node

onready var Resources = get_node("/root/Resources")

const EXTENSION = "json" # Default file extension to use

# --Public Functions--

func write(namespace: String, data: Dictionary) -> String:
	var path = _createPath(namespace, EXTENSION)
	var save_data = File.new()
	if save_data.open(path, File.WRITE) == OK:
		save_data.store_line(to_json(data))
	save_data.close()
	return(path)

func read(namespace: String) -> Dictionary:
	var output: Dictionary
	var path = _createPath(namespace, EXTENSION)
	var load_data = File.new()
	if load_data.open(path, File.READ) == OK:
		var content: String = load_data.get_as_text()
		output = parse_json(content)
	load_data.close()
	return(output)

func exists(namespace: String) -> bool:
	var path = _createPath(namespace, EXTENSION)
	var directory = Directory.new();
	var fileExists = directory.file_exists(path)
	return(fileExists)

# --Private Functions--

func _createPath(namespace: String, extension: String) -> String:
	namespace = Resources.formatString(namespace)
	extension = Resources.cleanString(extension)
	var path: String = "user://" + namespace + "." + extension
	return(path)
