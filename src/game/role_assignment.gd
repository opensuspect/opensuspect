extends Node2D

onready var teamNameField: Label = $LabelTeamName
onready var roleNameField: Label = $LabelRoleName

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary) -> void:
	var id: int = get_tree().get_network_unique_id()
	teamNameField.text = roles[id]["team"]
	roleNameField.text = roles[id]["role"]
	# TODO: add character sprites to the CharacterSprites BoxContainer
