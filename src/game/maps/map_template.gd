extends Node2D

export var teamsRolesResource: Resource
export var voteResource: Resource

func _ready():
	teamsRolesResource.init()
