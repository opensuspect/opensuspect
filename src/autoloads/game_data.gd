extends Node

## HOW TO USE THE GAME DATA MANAGER
## EXAMPLES
## Saving game data:
# GameData.write("unique_namespace", dictionaryOfData)
# > "user://unique_namespace.json"
# GameData.write will return the path that the data was saved to.
#
## Reading game data:
# GameData.read("unique_namespace")
# > {"saved_data": "example"}
#
## Checking if data exists:
# GameData.exists("unique_namespace")
# > true
# Boolean of whether the data file exists
#
## Getting the path to a data file:
# GameData.getPath("unique_namespace")
# > "user://unique_namespace.json"

onready var Resources = get_node("/root/Resources")

const EXTENSION = "json" # Default file extension to use

# --Public Functions--

## Write data to user directory
func write(namespace: String, data: Dictionary) -> String:
	var path = _createPath(namespace, EXTENSION)
	var save_data = File.new()
	if save_data.open(path, File.WRITE) == OK:
		save_data.store_line(to_json(data)) # Convert data to json and write it to file
	save_data.close()
	return(path)

## Read data from data file in user directory
func read(namespace: String) -> Dictionary:
	var output: Dictionary
	var path = _createPath(namespace, EXTENSION)
	var load_data = File.new()
	if load_data.open(path, File.READ) == OK:
		var content: String = load_data.get_as_text()
		output = parse_json(content) # Parse json from data file
	load_data.close()
	return(output)

func exists(namespace: String) -> bool:
	var path = _createPath(namespace, EXTENSION)
	var directory = Directory.new();
	var fileExists = directory.file_exists(path)
	return(fileExists)

func getPath(namespace) -> String:
	var output = _createPath(namespace, EXTENSION)
	return(output)

# --Private Functions--

# Creates the path to use from the namespace, cleaning up the strings first
func _createPath(namespace: String, extension: String) -> String:
	namespace = Resources.formatString(namespace) # Replace special characters with underscore
	extension = Resources.cleanString(extension) # Remove special characters
	var path: String = "user://" + namespace + "." + extension
	return(path)
