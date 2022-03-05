extends Node2D

onready var teamNameField: Label = $LabelTeamName
onready var roleNameField: Label = $LabelRoleName
onready var characterList: HBoxContainer = $CharacterSprites

# Converts a list of dictionaries into a dictionary of lits.
func zip(input: Array) -> Dictionary:
	var output: Dictionary
	for dict in input:
		for key in dict:
			if key in output:
				output[key].append(dict[key])
			else:
				output[key] = [dict[key]]
	return output

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary, rolesToShow: Array) -> void:
	## Get current player's role and team
	var id: int = get_tree().get_network_unique_id()
	teamNameField.text = roles[id]["team"]
	roleNameField.text = roles[id]["role"]
	## Clear character icons from previous game
	for nodeToRemove in characterList.get_children():
		nodeToRemove.free()
	## Preload character icons
	var characterIconRes: Resource = ResourceLoader.load("res://game/character/character_role_screen.tscn")
	## Convert list of roles to display
	var toShowLists: Dictionary = zip(rolesToShow)
	## For each character
	for character in roles:
		## If this role is not for show, skip
		if toShowLists["team"].count(roles[character]["team"]) == 0 and toShowLists["role"].count(roles[character]["role"]) == 0:
			continue
		## Creates a character instance and adds to scene tree
		var newCharacterIcon: Control = characterIconRes.instance()
		characterList.add_child(newCharacterIcon)
		## Gets player name and character outfit,
		## and applies to the icon
		var characterRes: CharacterResource = Characters.getCharacterResource(character)
		var characterName: String = Connections.listConnections[character]
		newCharacterIcon.setName(characterName, characterRes.getNameColor())
		newCharacterIcon.applyConfig(characterRes.getOutfit(), characterRes.getColors())
