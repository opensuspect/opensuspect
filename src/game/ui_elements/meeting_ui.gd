extends ColorRect

onready var voteOptions: VBoxContainer = $MainBox/VoteSide/VoteOptions
var characterVote: String = "res://game/ui_elements/character_vote.tscn"

var votableCharacters: Dictionary = {}

func _focus() -> void:
	removeOptions()
	for characterId in Characters.getCharacterKeys():
		addCharacter(characterId)

func removeOptions() -> void:
	for childNode in votableCharacters.values():
		childNode.queue_free()
	votableCharacters = {}

func addCharacter(characterId: int) -> void:
	var newVoteItem: HBoxContainer = ResourceLoader.load(characterVote).instance()
	var characterRes: CharacterResource = Characters.getCharacterResource(characterId)
	votableCharacters[characterId] = newVoteItem
	newVoteItem.setId(characterId)
	newVoteItem.setName(characterRes.getCharacterName())
	newVoteItem.setAppearance(characterRes.getOutfit(), characterRes.getColors())
	newVoteItem.connect("voteCast", self, "receiveVote")
	voteOptions.add_child(newVoteItem)

func receiveVote(votedFor: int) -> void:
	for id in votableCharacters:
		if id == votedFor:
			votableCharacters[id].changeTextColor(Color.yellow)
		else:
			votableCharacters[id].changeTextColor(Color.gray)
	TransitionHandler.gameScene.voteCast(votedFor)
