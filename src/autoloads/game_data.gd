extends Node

onready var Resources = get_node("/root/Resources")

# --Public Functions--

func write(namespace: String, data: Dictionary) -> String:
	namespace = Resources.formatString(namespace)
	var path = "user://" + namespace + ".json"
	var save_data = File.new()
	if save_data.open(path, File.WRITE) == OK:
		save_data.store_line(to_json(data))
	save_data.close()
	return(path)

func read(namespace: String) -> Dictionary:
	var output: Dictionary
	namespace = Resources.formatString(namespace)
	var path = "user://" + namespace + ".json"
	var load_data = File.new()
	if load_data.open(path, File.READ) == OK:
		var content: String = load_data.get_as_text()
		output = parse_json(content)
	load_data.close()
	return(output)
