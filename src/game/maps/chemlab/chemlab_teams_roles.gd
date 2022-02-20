extends TeamsRolesTemplate

var random

func init():
	teamNames = ["Agents", "CIA", "Yugoslavs"]
	roleNames = {"Agents": ["Agent", "Counter-intelligence"],
				"CIA": ["Infiltrator"],
				"Yugoslavs": ["Infiltrator"]}
	# Counter-intelligence agents are unknown to everyone else
	teamRoleAlias = [{	"who":  {"team": "Agents", "role": "Agent"},
						"whom": {"team": "Agents", "role": "Counter-intelligence"},
						"as":   {"team": "Agents", "role": "Agent"}},
					{	"who":  {"team": "CIA", "role": "Infiltrator"},
						"whom": {"team": "Agents", "role": "Counter-intelligence"},
						"as":   {"team": "Agents", "role": "Agent"}},
					{	"who":  {"team": "Yugoslavs", "role": "Infiltrator"},
						"whom": {"team": "Agents", "role": "Counter-intelligence"},
						"as":   {"team": "Agents", "role": "Agent"}},
	# Infiltrators are unknown to regular agents and infiltrators of other teams
					{	"who":  {"team": "Agents", "role": "Agent"},
						"whom": {"team": "CIA", "role": "Infiltrator"},
						"as":   {"team": "Agents", "role": "Agent"}},
					{	"who":  {"team": "Agents", "role": "Agent"},
						"whom": {"team": "Yugoslavs", "role": "Infiltrator"},
						"as":   {"team": "Agents", "role": "Agent"}},
					{	"who":  {"team": "CIA", "role": "Infiltrator"},
						"whom": {"team": "Yugoslavs", "role": "Infiltrator"},
						"as":   {"team": "Agents", "role": "Agent"}},
					{	"who":  {"team": "Yugoslavs", "role": "Infiltrator"},
						"whom": {"team": "CIA", "role": "Infiltrator"},
						"as":   {"team": "Agents", "role": "Agent"}}]
	teamRoleColors = {	["Agents", "Agent"]: Color.white,
						["Agents", "Counter-intelligence"]: Color.yellow,
						["CIA", "Infiltrator"]: Color.aqua,
						["Yugoslavs", "Infiltrator"]: Color.pink}
	random = RandomNumberGenerator.new()
	random.randomize()

func getAlisases() -> Array:
	return teamRoleAlias

func assignTeamsRoles(characterList: Array) -> Dictionary:
	var teamsRoles: Dictionary
	var chosen: int
	if len(characterList) < 10:
		var infiltNum: int = int(len(characterList) / 5) + 1
		var counterNum: int = 0
		if len(characterList) % 5 < 4 and len(characterList) > 1:
			counterNum = 1
		while infiltNum > 0:
			chosen = random.randi() % len(characterList)
			if not teamsRoles.has(characterList[chosen]):
				teamsRoles[characterList[chosen]] = {"team": "CIA", "role": "Infiltrator"}
				infiltNum -= 1
		while counterNum > 0:
			chosen = random.randi() % len(characterList)
			if not teamsRoles.has(characterList[chosen]):
				teamsRoles[characterList[chosen]] = {"team": "Agents",
													"role": "Counter-intelligence"}
				counterNum -= 1
	else:
		pass
	for character in characterList:
		if not teamsRoles.has(character):
			teamsRoles[character] = {"team": "Agents", "role": "Agent"}
	return teamsRoles
