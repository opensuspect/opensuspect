extends Node2D

onready var teamNameField: Label = $LabelTeamName
onready var roleNameField: Label = $LabelRoleName
onready var rolesTest: Label = $CharacterSprites/RolesTest

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary) -> void:
	var id: int = get_tree().get_network_unique_id()
	teamNameField.text = roles[id]["team"]
	roleNameField.text = roles[id]["role"]
	# TODO: add character sprites to the CharacterSprites BoxContainer
	rolesTest.text = ""
	for character in roles:
		rolesTest.text = rolesTest.text + str(character) + " "
		rolesTest.text = rolesTest.text + roles[character]["team"] + ", "
		rolesTest.text = rolesTest.text + roles[character]["role"] + "\n"
