extends Resource
class_name TeamsRolesTemplate

var teamNames: Array = []
var roleNames: Dictionary = {}

func init():
	teamNames = ["Agents"]
	roleNames = {"Agents": ["Agent"]}

func assignTeamsRoles(characterList: Array) -> Dictionary:
	var teamsRoles: Dictionary
	for character in characterList:
		teamsRoles[character] = {"team": "Agents", "role": "Agent"}
	return teamsRoles
