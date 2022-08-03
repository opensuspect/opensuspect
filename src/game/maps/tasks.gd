extends YSort

var taskResources: Dictionary = {}
var interactAreas: Dictionary = {}

func _ready():
	var taskRes: TaskResource
	TransitionHandler.gameScene.setTaskHandler(self)
	var myCharacter: CharacterResource = null
	if not Connections.isDedicatedServer():
		myCharacter = Characters.getMyCharacterResource()
	for taskNode in get_children():
		taskRes = taskNode.taskResource
		taskResources[taskNode.name] = taskRes
		interactAreas[taskNode.interactArea] = taskRes
		taskRes.init(taskNode)
		taskRes.connect("stateChanged", self, "taskChanged")
		taskRes.connect("action", self, "taskActionAttempt")
		if myCharacter != null:
			taskRes.connect("activateUi", myCharacter, "setTaskMode")
			taskRes.connect("deactivateUi", myCharacter, "endTaskMode")

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
	
