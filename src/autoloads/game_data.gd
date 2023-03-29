extends Node

## HOW TO USE THE GAME DATA MANAGER
## EXAMPLES
## Saving game data:
# GameData.write("unique_scope", dictionaryOfData)
# > "user://unique_scope.json"
# GameData.write will return the path that the data was saved to.
#
## Reading game data:
# GameData.read("unique_scope")
# > {"saved_data": "example"}
#
## Checking if data exists:
# GameData.exists("unique_scope")
# > true
# Boolean of whether the data file exists
#
## Getting the path to a data file:
# GameData.getPath("unique_scope")
# > "user://unique_scope.json"

const EXTENSION = "json" # Default file extension to use

# --Public Functions--

## Write data to user directory
func write(scope: String, data: Dictionary) -> String:
	var path = _createPath(scope, EXTENSION)
	var save_data = FileAccess.open(path, FileAccess.WRITE)
	save_data.store_line(JSON.new().stringify(data)) # Convert data to json and write it to file
	save_data.close()
	return(path)

## Read data from data file in user directory
func read(scope: String) -> Dictionary:
	var output: Dictionary
	var path = _createPath(scope, EXTENSION)
	var load_data = FileAccess.open(path, FileAccess.READ)
	var content: String = load_data.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(content) # Parse json from data file
	output = test_json_conv.get_data()
	load_data.close()
	return(output)

func exists(scope: String) -> bool:
	var path = _createPath(scope, EXTENSION)
	var directory = DirAccess.open(path.get_base_dir());
	var fileExists = directory.file_exists(path)
	return(fileExists)

func getPath(scope) -> String:
	var output = _createPath(scope, EXTENSION)
	return(output)

# --Private Functions--

# Creates the path to use from the scope, cleaning up the strings first
func _createPath(scope: String, extension: String) -> String:
	scope = Resources.formatString(scope) # Replace special characters with underscore
	extension = Resources.cleanString(extension) # Remove special characters
	var path: String = "user://" + scope + "." + extension
	return(path)
