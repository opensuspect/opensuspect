extends Node2D

@export var teamsRolesResource: Resource
@export var voteResource: Resource
@onready var taskNodes: Node2D = $TaskNodes
@onready var playerCamera: Camera2D = $CustomCamera

var hudNode: Control = null

func _ready():
	teamsRolesResource.init()
	playerCamera.make_current()

func setHudNode(newHudNode: Control):
	assert(hudNode == null) #,"This should only be set once")
	assert(newHudNode != null)
	hudNode = newHudNode

func taskInteract(interactArea: Area2D, action: String) -> void:
	assert(interactArea in taskNodes.interactAreas) #,"Task interact area not registered to task?")
	var taskRes: Resource # TaskResource
	taskRes = taskNodes.interactAreas[interactArea]
	hudNode.taskInteract(taskRes, action)
