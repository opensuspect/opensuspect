extends Node

func load_files_in_dir_with_exts(directory: String, exts: PoolStringArray) -> Array:
	var paths: Array = get_file_paths_in_dir_with_exts(directory, exts)
	var resources: Array = []
	for path in paths:
		var res: Resource = load(path)
		resources.append(res)
	return resources

func get_file_paths_in_dir_with_exts(directory: String, exts: PoolStringArray) -> Array:
	var paths: Array = []
	for ext in exts:
		paths += get_file_paths_in_dir(directory, ext)
	return paths

func get_file_paths_in_dir(directory: String, ext: String = "") -> Array:
	var paths: Array = []
	var dir = Directory.new()
	dir.open(directory)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			# completely break out of the loop
			break
		# if file path doesn't have the right extension
		if not is_valid_file_name(file, ext):
			# skip to the next iteration of the loop
			continue
		var path: String = directory
		if not path.ends_with("/"):
			path += "/"
		path += file
		paths.append(path)
	dir.list_dir_end()
	return paths

func is_valid_file_name(file_name: String, ext: String = "") -> bool:
	if file_name == "":
		return false
	# if file path doesn't have the right extension
	if ext != "" and not file_name.ends_with(ext):
		return false
		# don't include non-files
	if file_name == "." or file_name == "..":
		return false
	# if file is actually a folder
	if file_name.split(".").size() < 2:
		return false
	return true

func pick_random(array: Array):
	var random_index : int = 0
	if len(array) > 0:
		random_index = randi() % len(array)
	return array[random_index]
