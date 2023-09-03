extends Resource
class_name TaskResource

export var buttonSprite: Texture
export var taskPopUpName: String
export var inputVariables: Array
export var outputVariables: Array

# inputProviders will be a dictionary in which the keys will be set from the
# array elements of inputVariables, and the values will be set to the resource
# instance providing an output matching the input required here.
var _inputProviders: Dictionary = {}

var taskPopUpPath: String
var taskUiNode: Node = null
var taskObjectNode: YSort setget nothing, getTaskObjectNode
var name: String setget nothing, getName

var taskState: Dictionary = {}
var items: Dictionary = {}

signal activateUi
signal deactivateUi
signal stateChanged
signal action

func getTaskObjectNode() -> YSort:
	return taskObjectNode

func getTaskUiNode() -> Node:
	return taskUiNode

func getName() -> String:
	return name

func getTaskPosition() -> Vector2:
	return taskObjectNode.position

# warning-ignore:unused_argument
func nothing(anything) -> void:
	assert(false, "Can't change this on the fly")

func getItemResources() -> Dictionary:
	return items.duplicate()

func init(newNode: YSort) -> void:
	assert(taskObjectNode == null)
	taskObjectNode = newNode
	name = taskObjectNode.name
	var universalTaskUis: Dictionary
	var mapTaskUis: Dictionary
	var mapName: String = TransitionHandler.gameScene.actualMapName
	var mapTaskPaths: String
	mapTaskPaths = "res://game/maps/" + mapName + "/ui_elements/tasks"
	universalTaskUis = Resources.listDirectory("res://game/tasks/ui_elements", ["tscn"])
	mapTaskUis = Resources.listDirectory(mapTaskPaths, ["tscn"])
	if taskPopUpName in mapTaskUis:
		taskPopUpPath = mapTaskUis[taskPopUpName]["path"]
	elif taskPopUpName in universalTaskUis:
		taskPopUpPath = universalTaskUis[taskPopUpName]["path"]
	else:
		assert(false, "invalid task UI name")

func addItem(itemRes: Resource, position: String) -> void:
	items[position] = itemRes

func interact() -> void:
	Scenes.overlay(taskPopUpPath, self)


# warning-ignore:return_value_discarded
func activateUi(uiNode: Node) -> Dictionary:
	taskUiNode = uiNode
	taskUiNode.connect("stateChanged", self, "stateChanged")
	# warning-ignore:return_value_discarded
	taskUiNode.connect("action", self, "action")
	# warning-ignore:return_value_discarded
	taskUiNode.connect("deactivate", self, "deactivateUi")
	emit_signal("activateUi")
	return taskState.duplicate()

func deactivateUi() -> void:
	taskUiNode.disconnect("stateChanged", self, "stateChanged")
	taskUiNode.disconnect("action", self, "action")
	taskUiNode.disconnect("deactivate", self, "deactivateUi")
	taskUiNode = null
	emit_signal("deactivateUi")

func stateChanged(newState: Dictionary) -> void:
	for key in newState:
		taskState[key] = newState[key]
	emit_signal("stateChanged", self, taskState)

func action(actions: Dictionary) -> void:
	emit_signal("action", self, actions)

func attemptItemPickOut(itemId: int) -> void:
	var playerCharacter = Characters.getMyCharacterResource()
	for itemLoc in items:
		var itemRes = items[itemLoc]
		if itemRes.getId() == itemId:
			if not playerCharacter.canPickUpItem(itemRes):
				return
			## Tell the server to attempt picking the item up
			TransitionHandler.gameScene.itemPickUpAttempt(itemId)
			return
# warning-ignore:unused_argument
func canItemBePickedOut(intemId: int) -> bool:
	return true

# warning-ignore:unused_argument
func removeItem(itemRes: Resource, characterRes: Resource) -> void:
	for itemLoc in items:
		if items[itemLoc] == itemRes:
			itemRes.removeFromTask()
			# warning-ignore:return_value_discarded
			items.erase(itemLoc)
			return

func stateRemoteChange(newState: Dictionary) -> bool:
	for key in newState:
		taskState[key] = newState[key]
	if taskUiNode != null:
		taskUiNode.changedTaskState(taskState)
		taskUiNode.changedItemButtons([])
	return true

func setInputProvider(inputName: String, providerRes: TaskResource) -> void:
	if inputName in _inputProviders:
		assert (false, "Can't change the input provider once it has been set.")
		return
	_inputProviders[inputName] = providerRes

func getInput(inputName: String):
	if not inputName in _inputProviders:
		assert (false, "trying to access a non-existent input")
		return
	return _inputProviders[inputName].returnOutput(inputName)

func returnOutput(outputName: String):
	if not outputName in outputVariables:
		assert (false, "The required output can not be provided")
		return null
	return taskState[outputName]
