extends TaskResource
class_name ChemCabResource

func init(newNode: YSort) -> void:
	.init(newNode)
	taskState["door"] = false

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
