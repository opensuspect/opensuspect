extends VoteMechanicsTemplate
class_name ChemlabVote

func allVoted() -> bool:
	var allCharIds = Characters.getCharacterKeys()
	for characterId in allCharIds:
		if not Characters.getCharacterResource(characterId).isAlive():
			continue
		if not characterId in voteTally:
			return false
	return true

func getVoteTime() -> float:
	return 90.9

func votees() -> Array:
	var liveCharacters: Array = []
	for characterKey in Characters.getCharacterKeys():
		if Characters.getCharacterResource(characterKey).isAlive():
			liveCharacters.append(characterKey)
	return liveCharacters

func voteOptions() -> Array:
	var liveCharacters: Array = []
	for characterKey in Characters.getCharacterKeys():
		if Characters.getCharacterResource(characterKey).isAlive():
			liveCharacters.append(characterKey)
	return liveCharacters
