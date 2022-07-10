extends YSort

var taskResources: Array = []
var interactAreas: Dictionary = {}

func _ready():
	for taskNode in get_children():
		taskResources.append(taskNode.taskResource)
		interactAreas[taskNode.interactArea] = taskNode.taskResource

#func _process(delta):
#	pass
