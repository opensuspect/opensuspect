extends Resource
class_name TaskResource

export var buttonSprite: Texture

var taskObjectNode: YSort setget nothing, getTaskObjectNode

func getTaskObjectNode() -> YSort:
	return taskObjectNode

func nothing(taskObjectNode: YSort) -> void:
	assert(false, "Can't change this on the fly")

func init(newNode: YSort) -> void:
	assert(taskObjectNode == null)
	taskObjectNode = newNode

func interact() -> void:
	print_debug("Task activated")
