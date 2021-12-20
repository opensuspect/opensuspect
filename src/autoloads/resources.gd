extends Node

## HOW TO USE THE RESOURCE MANAGER
## Example: get a list of resources in a set of directories
## Dictionary of directories, with the namespace, followed by the directory path:
#	var dirs: Dictionary = {
#	"Resource 1": "res://examples/resource1",
#	"Resource 2": "res://examples/resource2"
#	}
#
## Array of file types to use (only files with these extensions will be listed):
#	var file_types: Array = [".png", ".svg"]
#
## Pass the two variables into the list function:
#	Resources.list(dirs, file_types)
#	> {Resource 1:{Test 1:test_1.png, Test 2:test_2.svg}, Resource 2:{Test 3:test_3.svg}}
#
## Select only resources in "Resource 1":
#	Resources.list(dirs, file_types)["Resource 1"]
#	> {Test 1:test_1.png, Test 2:test_2.svg}

# --Public Functions--

# Returns a dictionary of all resources from a given directory dictionary
func list(directories: Dictionary, types: Array) -> Dictionary:
	var resources: Dictionary = {} # Initialise resources dictionary
	for folder in directories.keys(): # Iterate over each folder specified, by their namespace (key)
		var files = _listFilesInDirectory(directories[folder], types) # List files in each folder
		# Add each file to the output dictionary
		for file in files :
			resources = _filesToDictionary(resources, folder, file, directories[folder], types)
	return(resources) # Return the dictionary of namespaced resources

# --Private Functions--

# Lists all files in a path, that have the correct file extensions
func _listFilesInDirectory(path: String, types: Array) -> Array:
	var files: Array # Defunes the array to be returned
	var dir = Directory.new() # Makes a new directory object
	dir.open(path) # Opens the directory given in "path"
	dir.list_dir_begin() # List files in the directory from the beginning
	while true:
		var file: String = dir.get_next() # Gets the next file in the list
		if file == "": # If the file is "", means the end of the directory has been found
			break # Stops the loop after the end of the directory has been found
		else:
			for type in types: # Iterates over each specified file extension
				if file.ends_with(type): # Checks if the file has the extension
					files.append(file) # If it does, add it to the files array
	return files # Return the files array

# Creates a dictionary of the files in a directory
func _filesToDictionary(resources: Dictionary, namespace: String, file: String, path: String, types: Array) -> Dictionary:
	var resource: String # Defines the resource string 
	for type in types: # Iterates over each specified file extension
		if file.ends_with(type): # Checks if the file has the extension
			resource = file.trim_suffix(type) # If it does, remove the extension, and set this as "resource"
	resource = _formatString(resource) # Format the resource string for use in game
	path = path + "/" + file # Create the full file path to the resource
	if not resources.has(namespace): # Initialise the resource dictionary to have the namespace
		resources[namespace] = {}
	resources[namespace][resource] = path # Set the path in the resources dictionary
	return(resources) # Return the resources dictionary

# Formats a string to remove any special characters
func _formatString(string: String) -> String:
	var regex = RegEx.new() # Create a new RegEx object
	regex.compile("[^A-Za-z0-9_]+") # Select any special characters
	for word in regex.search_all(string): # Iterate over the instances of the regex in the input string
		string = string.replace(word.get_string(), "_") # Replace all special characters with underscores
	return(string) # Return the string (capitalize it later if it is to be used in game)
