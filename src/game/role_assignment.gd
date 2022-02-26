extends Node2D

onready var teamNameField: Label = $LabelTeamName
onready var roleNameField: Label = $LabelRoleName
onready var characterList: HBoxContainer = $CharacterSprites

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary) -> void:
	var id: int = get_tree().get_network_unique_id()
	teamNameField.text = roles[id]["team"]
	roleNameField.text = roles[id]["role"]
	for nodeToRemove in characterList.get_children():
		nodeToRemove.free()
	# TODO: add character sprites to the CharacterSprites BoxContainer
	var characterIconRes: Resource = ResourceLoader.load("res://game/character/character_role_screen.tscn")
	for character in roles:
		var newCharacterIcon: Control = characterIconRes.instance()
		characterList.add_child(newCharacterIcon)
		var characterRes: CharacterResource = Characters.getCharacterResource(character)
		var characterName: String = Connections.listConnections[character]
		newCharacterIcon.setName(characterName, characterRes.getNameColor())
		newCharacterIcon.applyConfig(characterRes.getOutfit(), characterRes.getColors())
