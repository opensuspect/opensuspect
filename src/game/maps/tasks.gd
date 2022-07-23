extends YSort

var taskResources: Dictionary = {}
var interactAreas: Dictionary = {}

func _ready():
	var taskRes: TaskResource
	for taskNode in get_children():
		taskRes = taskNode.taskResource
		taskResources[taskNode.name] = taskRes
		interactAreas[taskNode.interactArea] = taskRes
		taskRes.connect("stateChanged", self, "taskChanged")
		taskRes.connect("action", self, "taskActionAttempt")

func taskChanged(taskRes: TaskResource, newState: Dictionary) -> void:
	var taskData: Dictionary = {}
	var index: int = taskResources.values().find(taskRes)
	taskData["name"] = taskResources.keys()[index]
	taskData["newState"] = newState
	Connections.queueDataToSend("taskChanged", taskData, -1)

func taskActionAttempt(taskRes: TaskResource, actions: Dictionary) -> void:
	pass

func taskRemoteChanged(receivedData: Dictionary) -> Dictionary:
	var taskRes: TaskResource
	var newState: Dictionary = {}
	taskRes = taskResources[receivedData["name"]]
	newState = receivedData["newState"]
	if taskRes.stateRemoteChange(newState):
		return receivedData
	return {"name": receivedData["name"], "newState": taskRes.taskState}
	
