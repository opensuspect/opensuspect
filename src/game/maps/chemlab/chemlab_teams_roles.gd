extends TeamsRolesTemplate

var random

func init():
	teamNames = ["Agents", "CIA", "Yugoslavs"]
	roleNames = {"Agents": ["Agent", "Counter-intelligence"],
				"CIA": ["Infiltrator"],
				"Yugoslavs": ["Infiltrator"]}
	random = RandomNumberGenerator.new()
	random.randomize()

func assignTeamsRoles(characterList: Array) -> Dictionary:
	var teamsRoles: Dictionary
	var chosen: int
	if len(characterList) < 10:
		var infiltNum: int = int(len(characterList) / 5) + 1
		while infiltNum > 0:
			chosen = random.randi() % len(characterList)
			if not teamsRoles.has(characterList[chosen]):
				teamsRoles[characterList[chosen]] = {"team": "CIA", "role": "Infiltrator"}
				infiltNum -= 1
	else:
		pass
	for character in characterList:
		if not teamsRoles.has(character):
			teamsRoles[character] = {"team": "Agents", "role": "Agent"}
	return teamsRoles
