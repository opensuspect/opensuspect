extends Node2D

@onready var teamNameField: Label = $LabelTeamName
@onready var roleNameField: Label = $LabelRoleName
@onready var characterList: HBoxContainer = $CharacterSprites

func isDictInArray(input: Array, what: Dictionary) -> bool:
	for element in input:
		var check: bool = true
		for key in what:
			if element.has(key):
				if element[key] != what[key]:
					check = false
			else:
				check = false
		if check == true:
			return true
	return false

func _ready():
	TransitionHandler.gameScene.connect("teamsRolesAssigned", Callable(self, "showTeamsRoles"))

func showTeamsRoles(roles: Dictionary, rolesToShow: Array) -> void:
	if Connections.isDedicatedServer():
		return
	## Get current player's role and team
	var id: int = Connections.getMyId()
	teamNameField.text = roles[id]["team"]
	roleNameField.text = roles[id]["role"]
	## Clear character icons from previous game
	for nodeToRemove in characterList.get_children():
		nodeToRemove.free()
	## Preload character icons
	var characterIconRes: Resource = ResourceLoader.load("res://game/character/character_role_screen.tscn")
	## For each character
	for character in roles:
		## If this role is not for show, skip
		if not isDictInArray(rolesToShow, roles[character]):
			continue
		## Creates a character instance and adds to scene tree
		var newCharacterIcon: Control = characterIconRes.instantiate()
		characterList.add_child(newCharacterIcon)
		## Gets player name and character outfit,
		## and applies to the icon
		var characterRes: CharacterResource = Characters.getCharacterResource(character)
		var characterName: String = Connections.listConnections[character]
		newCharacterIcon.setName(characterName, characterRes.getNameColor())
		newCharacterIcon.applyConfig(characterRes.getOutfit(), characterRes.getColors())
