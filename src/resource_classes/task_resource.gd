extends Resource
class_name TaskResource

@export var buttonSprite: Texture2D
@export var taskPopUpName: String
@export var inputVariables: Array
@export var outputVariables: Array

# inputProviders will be a dictionary in which the keys will be set from the
# array elements of inputVariables, and the values will be set to the resource
# instance providing an output matching the input required here.
var _inputProviders: Dictionary = {}

var taskPopUpPath: String
var _taskUiNode: Node = null
var taskUiNode: Node: get = getTaskUiNode, set = toss
var _taskObjectNode: Node2D
var taskObjectNode: Node2D: get = getTaskObjectNode, set = toss
var _name: String
var name: String: get = getName, set = toss

var taskState: Dictionary = {}
var items: Dictionary = {}

signal activate_ui
signal deactivate_ui
signal state_changed
signal run_action

func getTaskObjectNode() -> Node2D:
	return _taskObjectNode

func getTaskUiNode() -> Node:
	return _taskUiNode

func getName() -> String:
	return _name

func getTaskPosition() -> Vector2:
	return taskObjectNode.position

func toss(anything) -> void:
	assert(false) #,"Can't change this on the fly")

func getItemResources() -> Dictionary:
	return items.duplicate()

func init(newNode: Node2D) -> void:
	assert(taskObjectNode == null)
	_taskObjectNode = newNode
	_name = taskObjectNode.name
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
		assert(false) #,"invalid task UI name")

func addItem(itemRes: Resource, position: String) -> void:
	items[position] = itemRes

func interact() -> void:
	Scenes.overlay(taskPopUpPath, self)

func activateUi(uiNode: Node) -> Dictionary:
	_taskUiNode = uiNode
	taskUiNode.connect("state_changed", Callable(self, "stateChanged"))
	taskUiNode.connect("run_action", Callable(self, "action"))
	taskUiNode.connect("deactivate_ui", Callable(self, "deactivateUi"))
	emit_signal("activate_ui")
	return taskState.duplicate()

func deactivateUi() -> void:
	taskUiNode.disconnect("state_changed", Callable(self, "stateChanged"))
	taskUiNode.disconnect("run_action", Callable(self, "action"))
	taskUiNode.disconnect("deactivate_ui", Callable(self, "deactivateUi"))
	_taskUiNode = null
	emit_signal("deactivate_ui")

func stateChanged(newState: Dictionary) -> void:
	for key in newState:
		taskState[key] = newState[key]
	emit_signal("state_changed", self, taskState)

func action(actions: Dictionary) -> void:
	emit_signal("run_action", self, actions)

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

func canItemBePickedOut(intemId: int) -> bool:
	return true

func removeItem(itemRes: Resource, characterRes: Resource) -> void:
	for itemLoc in items:
		if items[itemLoc] == itemRes:
			itemRes.removeFromTask()
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
