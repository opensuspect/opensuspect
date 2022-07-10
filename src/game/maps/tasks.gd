extends YSort

var taskResources: Array = []

func _ready():
	for taskNode in get_children():
		taskResources.append(taskNode.taskResource)

#func _process(delta):
#	pass
