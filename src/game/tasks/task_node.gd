extends YSort

export var taskResource: Resource
onready var interactArea: Area2D = $InteractionArea

func _ready():
	taskResource.init()
