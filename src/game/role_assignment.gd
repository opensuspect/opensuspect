extends Control

onready var teamNameField: Label = $Panel/MissionBriefing/LeftPage/Briefing/Team/LabelTeamName
onready var roleNameField: Label = $Panel/MissionBriefing/LeftPage/Briefing/Role/LabelRoleName
onready var missionField: TextEdit = $Panel/MissionBriefing/LeftPage/Briefing/Mission/Description
onready var characterList: GridContainer = $Panel/MissionBriefing/RightPage/CharacterSprites

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
	TransitionHandler.gameScene.connect("teamsRolesAssigned", self, "showTeamsRoles")

func showTeamsRoles(roles: Dictionary, rolesToShow: Array, roleMissions: Dictionary) -> void:
	if Connections.isDedicatedServer():
		return
	## Get current player's role and team
	var id: int = get_tree().get_network_unique_id()
	var myTeam: String = roles[id]["team"]
	var myRole: String = roles[id]["role"]
	teamNameField.text = myTeam
	roleNameField.text = myRole
	missionField.text = roleMissions[[myTeam, myRole]]
	## Clear character icons from previous game
	for nodeToRemove in characterList.get_children():
		nodeToRemove.free()
	## Preload character icons
	var characterIconRes: Resource = ResourceLoader.load("res://game/character/character_role_screen.tscn")
	## Count characters to show and calculate size
	var characterNum: int = 0
	for character in roles:
		if isDictInArray(rolesToShow, roles[character]):
			characterNum += 1
	var columnNum: int = ceil(sqrt(characterNum))
	characterList.columns = columnNum
	var characterSize: int = min(min(
		characterList.rect_size.x / columnNum,
		characterList.rect_size.y / ceil(characterNum / float(columnNum)) - 60),
		400
	)
	## For each character
	var counter: int = 0
	for character in roles:
		## If this role is not for show, skip
		if not isDictInArray(rolesToShow, roles[character]):
			continue
		## Creates a character instance and adds to scene tree
		var newCharacterIcon: Control = characterIconRes.instance()
		newCharacterIcon.changeSize(characterSize)
		characterList.add_child(newCharacterIcon)
		counter += 1
		## Gets player name and character outfit,
		## and applies to the icon
		var characterRes: CharacterResource = Characters.getCharacterResource(character)
		var characterName: String = Connections.listConnections[character]
		var roleString: String = roles[character]["role"]
		newCharacterIcon.setName(characterName, roleString)
		newCharacterIcon.applyConfig(characterRes.getOutfit(), characterRes.getColors())
