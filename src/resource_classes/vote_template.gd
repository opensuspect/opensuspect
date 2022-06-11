extends Resource
class_name VoteMechanicsTemplate

var voteTally: Dictionary = {}

func receiveVote(voterId: int, voteeId: int) -> void:
	voteTally[voterId] = voteeId
	print_debug(voterId, voteeId)

func initialize() -> void:
	voteTally = {}

func allVoted() -> bool:
	return true
