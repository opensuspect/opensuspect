extends TaskResource
class_name ChemCabResource

func init(newNode: YSort) -> void:
	.init(newNode)
	taskState["door"] = false
	taskState["left handle pos"] = 0
	taskState["left handle rot"] = 0
	taskState["right handle pos"] = 0
	taskState["right handle rot"] = 0

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
