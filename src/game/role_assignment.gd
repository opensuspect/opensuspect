extends Node2D

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary) -> void:
	print_debug(roles)
