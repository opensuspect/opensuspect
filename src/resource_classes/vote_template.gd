extends Resource
class_name VoteMechanicsTemplate

var active: bool = false
var voteTally: Dictionary = {}
var timeToVote: float = 90.9

func voteOptions() -> Array:
	return Characters.getCharacterKeys()

func receiveVote(voterId: int, voteeId: int) -> void:
	voteTally[voterId] = voteeId

func initialize() -> void:
	voteTally = {}
	active = true

func allVoted() -> bool:
	return true

func voteStop() -> void:
	active = false
