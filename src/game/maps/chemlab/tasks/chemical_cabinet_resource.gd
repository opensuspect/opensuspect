extends TaskResource
class_name ChemCabResource

export var itemsContained: Dictionary = {"Powder Bottle": 10}

var _doorTimer: Timer
var _handleTimer: Timer

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
	_doorTimer = Timer.new()
	_doorTimer.one_shot = true
	_doorTimer.wait_time = 7
	_doorTimer.connect("timeout", self, "_doorAutoClose")
	taskObjectNode.add_child(_doorTimer)
	_handleTimer = Timer.new()
	_handleTimer.one_shot = true
	_handleTimer.wait_time = 7
	_handleTimer.connect("timeout", self, "_handleReset")
	taskObjectNode.add_child(_handleTimer)

func deactivateUi() -> void:
	.deactivateUi()

func stateChanged(newState: Dictionary) -> void:
	.stateChanged(newState)
	if "door" in newState:
		_setDoor(newState["door"])
	if _handleTimer != null and not _isHandleReset():
		_handleTimer.start()

func stateRemoteChange(newState: Dictionary) -> bool:
	.stateRemoteChange(newState)
	if "door" in newState:
		_setDoor(newState["door"])
	if _handleTimer != null and not _isHandleReset():
		_handleTimer.start()
	return true

func canItemBePickedOut(intemId: int) -> bool:
	return taskState["door"]

func removeItem(itemRes: Resource, characterRes: Resource) -> void:
	.removeItem(itemRes, characterRes)
	if taskUiNode != null:
		taskUiNode.itemsPickedOut(itemRes)
		if characterRes.isMainCharacter():
			taskUiNode.closeWindow()

# -------- Private functions -------------

func _setDoor(doorState: bool) -> void:
	if doorState:
		taskObjectNode.object.doorOpen()
		if _doorTimer != null:
			_doorTimer.start()
	else:
		taskObjectNode.object.doorClose()

func _doorAutoClose() -> void:
	stateChanged({"door": false})

func _handleReset() -> void:
	var newTaskState: Dictionary = {}
	newTaskState["left handle pos"] = 0
	newTaskState["left handle rot"] = 0
	newTaskState["right handle pos"] = 0
	newTaskState["right handle rot"] = 0
	stateChanged(newTaskState)

func _isHandleReset() -> bool:
	return (
		taskState["left handle pos"] == 0 and
		taskState["left handle rot"] == 0 and
		taskState["right handle pos"] == 0 and
		taskState["right handle rot"] == 0
	)
