extends TaskResource
class_name ChemCabResource

export var itemsContained: Dictionary = {"Powder Bottle": 10}

func init(newNode: YSort) -> void:
	.init(newNode)
	taskState["door"] = false
	taskState["left handle pos"] = 0
	taskState["left handle rot"] = 0
	taskState["right handle pos"] = 0
	taskState["right handle rot"] = 0
	if not Connections.isServer():
		return
	var position: String
	var shelfIndex: int = 0
	for itemName in itemsContained:
		if itemName == "":
			continue
		if shelfIndex > 2:
			break
		for index in range(itemsContained[itemName]):
			position = str(shelfIndex) + "-" + str(index)
			Items.createTaskItemServer(itemName, name, position)

func deactivateUi() -> void:
	.deactivateUi()

func stateChanged(newState: Dictionary) -> void:
	.stateChanged(newState)
	if "door" in newState:
		setDoor(newState["door"])

func setDoor(doorState: bool) -> void:
	if doorState:
		taskObjectNode.object.doorOpen()
	else:
		taskObjectNode.object.doorClose()

func stateRemoteChange(newState: Dictionary) -> bool:
	.stateRemoteChange(newState)
	if "door" in newState:
		setDoor(newState["door"])
	return true
