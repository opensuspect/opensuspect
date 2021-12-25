extends Node

## HOW TO USE THE RESOURCE MANAGER
## Example: get a list of resources in a set of directories
## Dictionary of directories, with the namespace, followed by the directory path:
#	var dirs: Dictionary = {
#	"Folder 1": "res://examples/folder1",
#	"Folder 2": "res://examples/folder2"
#	}
#
## Array of file types to use (only files with these extensions will be listed):
#	var file_types: Array = [".png", ".svg"]
#
## Pass the two variables into the list function:
#	Resources.list(dirs, file_types)
#	> {Folder 1:{test_1:res://.../test_1.png, test_2:res://.../test_2.svg}, Folder 2:{test_3:res://.../test_3.svg}}
#
## Select only resources in "Folder 1":
#	Resources.list(dirs, file_types)["Folder 1"]
#	> {test_1:res://.../test_1.png, test_2:res://.../test_2.svg}
#
## Get a random file from "Folder 1":
# Resources.getRandom("Folder 1", dirs, file_types)
# > {test_2:res://.../test_2.png}
#
## Get a random file for each folder
# Resources.getRandomOfEach(dirs, file_types)
# > {Folder 1:{test_2:res://.../test_2.png}, Folder 2:{test_3:res://.../test_3.png}}

# --Public Functions--

# Returns a dictionary of all resources from a given directory dictionary
func list(directories: Dictionary, types: PoolStringArray) -> Dictionary:
	var resources: Dictionary = {}
	for folder in directories.keys(): # Iterate over each folder specified, by their namespace (key)
		var files = _listFilesInDirectory(directories[folder], types) # List files in each folder
		# Add each file to the output dictionary
		resources[folder] = _filesToDictionary(folder, files, directories[folder], types)
	return(resources) # Return the dictionary of namespaced resources

# Returns the path of a specified resource
func getPath(resource: String, namespace: String, directories: Dictionary, types: PoolStringArray) -> String:
	var resources: Dictionary = list(directories, types) # Create the directory listing
	var wantedResource = _formatString(resource) # Format the string for optimal matching
	var output = "" # Set a blank output
	for file in resources[namespace].keys(): # Iterate through each file in the specified namespace
		if file == wantedResource: # Match the file name with the wanted resource
			output = resources[namespace][file] # Set output to the path of the file
	return(output)

# Returns a random resource from a given namespace
func getRandom(namespace: String, directories: Dictionary, types: PoolStringArray) -> Dictionary:
	var resources: Dictionary = list(directories, types) # Get a list of resources
	var dir = resources[namespace] # Get the required directory from the given namespace
	var files = dir.keys() # Get an array of the files in the directory
	var maxInt = files.size() # Get the size of the array
	var randInt = randi() % maxInt # Select a number between 0 and the size of maxInt
	var chosenFile = files[randInt] # Set the chosen file to the file in the array at the random position
	var output: Dictionary = {}
	output[chosenFile] = dir[chosenFile] # Set the output variable
	return(output) # Return the output variable

# Return a random file for each directory listed
func getRandomOfEach(directories: Dictionary, types: PoolStringArray) -> Dictionary:
	var output: Dictionary = {}
	for namespace in directories.keys(): # Iterate over the directories
		var random = getRandom(namespace, directories, types) # Get a random file for the directory
		output[namespace] = {}
		output[namespace] = random # Set the file for this directory to be the random file
	return(output) # Return the dictionary of random files

# --Private Functions--
func _ready():
	randomize()

# Lists all files in a path, that have the correct file extensions
func _listFilesInDirectory(path: String, types: PoolStringArray) -> Array:
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
	return(files) # Return the files array

# Creates a dictionary of the files in a directory
func _filesToDictionary(namespace: String, files: PoolStringArray, path: String, types: PoolStringArray) -> Dictionary:
	var output: Dictionary = {} # Defines the dictionary to output the files
	var resource: String = "" # Defines the resource string 
	for file in files:
		for type in types: # Iterates over each specified file extension
			if file.ends_with(type): # Checks if the file has the extension
				resource = file.trim_suffix(type) # If it does, remove the extension, and set this as "resource"
		resource = _formatString(resource) # Format the resource string for use in game
		var fullPath = path + "/" + file # Create the full file path to the resource
		output[resource] = fullPath # Set the path in the resources dictionary
	return(output) # Return the output dictionary

# Formats a string to remove any special characters
func _formatString(string: String) -> String:
	var regex = RegEx.new() # Create a new RegEx object
	regex.compile("[^A-Za-z0-9_]+") # Select any special characters
	for word in regex.search_all(string): # Iterate over the instances of the regex in the input string
		string = string.replace(word.get_string(), "_") # Replace all special characters with underscores
	return(string) # Return the string (capitalize it later if it is to be used in game)
