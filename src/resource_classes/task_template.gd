extends Resource
class_name TaskResource

export var buttonSprite: Texture
export var taskPopUpName: String

var taskPopUpPath: String
var taskUiNode: Node = null
var taskObjectNode: YSort setget nothing, getTaskObjectNode

var taskState: Dictionary = {}

signal stateChanged
signal action

func getTaskObjectNode() -> YSort:
	return taskObjectNode

func nothing(taskObjectNode: YSort) -> void:
	assert(false, "Can't change this on the fly")

func init(newNode: YSort) -> void:
	assert(taskObjectNode == null)
	taskObjectNode = newNode
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

func interact() -> void:
	Scenes.overlay(taskPopUpPath, self)

func activateUi(uiNode: Node) -> Dictionary:
	taskUiNode = uiNode
	taskUiNode.connect("stateChanged", self, "stateChanged")
	taskUiNode.connect("action", self, "action")
	taskUiNode.connect("deactivate", self, "deactivateUi")
	return taskState.duplicate()

func deactivateUi() -> void:
	taskUiNode.disconnect("stateChanged", self, "stateChanged")
	taskUiNode.disconnect("action", self, "action")
	taskUiNode.disconnect("deactivate", self, "deactivateUi")
	taskUiNode = null

func stateChanged(newState: Dictionary) -> void:
	for key in newState:
		taskState[key] = newState[key]
	emit_signal("stateChanged", self, taskState)

func action(actions: Dictionary) -> void:
	emit_signal("action", self, actions)

func stateRemoteChange(newState: Dictionary) -> bool:
	taskState = newState
	if taskUiNode != null:
		taskUiNode.changedTaskState(taskState)
	return true
