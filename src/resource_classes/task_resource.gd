extends Resource
class_name TaskResource

export var buttonSprite: Texture
export var taskPopUpName: String

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

func activateUi(uiNode: Node) -> Dictionary:
	taskUiNode = uiNode
	taskUiNode.connect("stateChanged", self, "stateChanged")
	taskUiNode.connect("action", self, "action")
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
	var playerCharacter: CharacterResource = Characters.getMyCharacterResource()
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
	return true
