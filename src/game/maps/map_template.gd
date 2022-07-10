extends YSort

export var teamsRolesResource: Resource
export var voteResource: Resource
onready var taskNodes: YSort = $TaskNodes

func _ready():
	teamsRolesResource.init()
