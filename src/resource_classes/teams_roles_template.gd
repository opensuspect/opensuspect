extends Resource
class_name TeamsRolesTemplate

var teamNames: Array = [] # A list of the teams
var roleNames: Dictionary = {} # A list of roles for each team
var teamRoleColors: Dictionary = {} # A list of team, role, color pairings
# A list of teams and roles that appear to others as different roles
# Follows the rule of "who" (team+role) sees "whom" (team+role) "as" what (team+role)
var teamRoleAlias: Array = []

# Examples:
# (1) We have two teams, and one of the teams is a secret infiltrator team:
#      teamNames = ["A", "B"]
#      roleNams = {"A": ["A1"], "B": ["B1"]}
#      teamRoleAlias = [{"who":  {"team": "A", "role": "A1"},
#                        "whom": {"team": "B", "role": "B1"},
#                        "as":   {"team": "A", "role": "A1"}}]
#  Here, the members of team "B" are only known to other members of team "B".
#  To the team "A", they look like they were in team "A".
#
#  (2) We have two teams and one team has a hidden role:
#      teamNames = ["A", "B"]
#      roleNames = {"A": ["A1", "A2"], "B": ["B1"]}
#      teamRoleAlias = [{"who":  {"team": "A", "role": "A1"},
#                        "whom": {"team": "A", "role": "A2"},
#                        "as":   {"team": "A", "role": "A1"}},
#                       {"who":  {"team": "B", "role": "B1"},
#                        "whom": {"team": "A", "role": "A2"},
#                        "as":   {"team": "A", "role": "A1"}}]
#  Here, members of the team A with role A1 will see the characters in team A
#  with role A2 as if they were A1. Similarly, the members of the team B with
#  role B1 will see A/A2 characters as A/A1. Therefore, only A/A2 characters will
#  know who are actually A/A2, to others they will look like A/A1.

func init():
	teamNames = ["Agents"]
	roleNames = {"Agents": ["Agent"]}
	teamRoleColors = {["Agents", "Agent"]: Color.white}
	teamRoleAlias = []

func getRoleColor(team: String, role: String) -> Color:
	var textColor: Color = Color.white
	var searchBase: Array = [team, role]
	if searchBase in teamRoleColors:
		textColor = teamRoleColors[searchBase]
	return textColor

func assignTeamsRoles(characterList: Array) -> Dictionary:
	var teamsRoles: Dictionary
	for character in characterList:
		teamsRoles[character] = {"team": "Agents", "role": "Agent"}
	return teamsRoles
