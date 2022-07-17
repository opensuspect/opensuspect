extends Resource
class_name TaskResource

export var buttonSprite: Texture
export var taskPopUpName: String

var taskPopUpPath: String
var taskUiNode: Node = null
var taskObjectNode: YSort setget nothing, getTaskObjectNode

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

func activateUi(uiNode: Node) -> void:
	taskUiNode = uiNode

func deactivateUi() -> void:
	taskUiNode = null
