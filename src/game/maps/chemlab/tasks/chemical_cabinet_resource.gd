extends TaskResource
class_name ChemCabResource

var doorOpen: bool = false

func activateUi(uiNode: Node) -> void:
	.activateUi(uiNode)
	if doorOpen:
		uiNode.doorOpen()
	else:
		uiNode.doorClose()

func deactivateUi() -> void:
	.deactivateUi()

func setDoor(doorState: bool) -> void:
	doorOpen = doorState
	if doorOpen:
		taskObjectNode.object.doorOpen()
	else:
		taskObjectNode.object.doorClose()
