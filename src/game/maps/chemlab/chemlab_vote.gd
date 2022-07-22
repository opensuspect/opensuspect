extends VoteMechanicsTemplate
class_name ChemlabVote

func allVoted() -> bool:
	var allCharIds = Characters.getCharacterKeys()
	for characterId in allCharIds:
		if not characterId in voteTally:
			return false
	return true

func getVoteTime() -> float:
	return 90.9
