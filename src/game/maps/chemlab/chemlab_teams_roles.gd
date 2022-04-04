extends TeamsRolesTemplate

var random

func init():
	teamNames = ["Agents", "CIA", "Yugoslavs"]
	roleNames = {"Agents": ["Agent", "Counter-intelligence"],
				"CIA": ["Infiltrator"],
				"Yugoslavs": ["Infiltrator"]}
	teamRoleColors = {	["Agents", "Agent"]: Color.white,
						["Agents", "Counter-intelligence"]: Color.yellow,
						["CIA", "Infiltrator"]: Color.aqua,
						["Yugoslavs", "Infiltrator"]: Color.pink}
	random = RandomNumberGenerator.new()
	random.randomize()

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

func getVisibleTeamRole(realTeamsRoles: Dictionary, myTeam: String, myRole: String) -> Dictionary:
	var visibleTeamRoles: Dictionary = realTeamsRoles.duplicate()
	## Based on player's team
	match myTeam:
		"Agents": ## If agents
			if myRole == "Agent": ## If regular agent, see everyone as agent
				for character in visibleTeamRoles.values():
					character["team"] = "Agents"
					character["role"] = "Agent"
		"CIA": ## If CIA infiltrator, can see other CIA
			for character in visibleTeamRoles.values():
				if character["team"] != "CIA":
					character["team"] = "Agents"
					character["role"] = "Agent"
		"Yugoslavs": ## If Yugoslav, can see other Yugoslavs
			for character in visibleTeamRoles.values():
				if character["team"] != "Yugoslavs":
					character["team"] = "Agents"
					character["role"] = "Agent"
	return visibleTeamRoles

func getTeamsRolesToShow(realTeamsRoles: Dictionary, myTeam: String, myRole: String) -> Array:
	match myTeam:
		"CIA":
			return [{"team": "CIA", "role": "Infiltrator"}]
		"Yugoslavs":
			return [{"team": "Yugoslavs", "role": "Infiltrator"}]
		"Agents":
			if myRole == "Agent":
				return [{"team": "Agents", "role": "Agent"}]
			else:
				return	[	{"team": "CIA", "role": "Infiltrator"},
							{"team": "Yugoslavs", "role": "Infiltrator"}]
		_:
			assert (false, "Team name is not set properly")
	return []

func assignAbilities(characterList: Array, teamsRoles: Dictionary) -> Dictionary:
	var abilities: Dictionary
	for character in characterList:
		abilities[character] = []
		if teamsRoles[character]["team"] == "CIA":
			var ability: Ability = GunAbility.new()
			abilities[character].append(ability)
	return abilities

func getAbilityByName(name: String) -> Ability:
	if name == "Gun":
		return GunAbility.new()
	return null
