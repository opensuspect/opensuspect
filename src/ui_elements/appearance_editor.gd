extends Node

onready var Resources = get_node("/root/Resources")
onready var Appearance = get_node("/root/Appearance")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var files = Resources.list(Appearance.directories, Appearance.extensions)
	for file in files.keys():
		for namespace in Appearance.groupClothing:
			if Appearance.groupClothing[namespace].has(file):
				pass
			else:
				var child = ItemList.new()
				child.name = file.capitalize()
				$TabContainer.add_child(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
