extends KinematicBody2D

# this script acts as the frontend for the players/controls the player node

# --Public Variables--

# network id corresponding to this player
var networkId: int

# the name of this player
var playerName: String

# --Private Variables--

# the PlayerResource corresponding to this player node
var _playerResource: PlayerResource



# --Public Functions--

# get tasks assigned to this player node
func getTasks() -> Dictionary:
	return _playerResource.getTasks()

func getOutfit() -> Dictionary:
	return _playerResource.getOutfit()

# get the player node that corresponds to this PlayerResource
func getPlayerResource() -> PlayerResource:
	return _playerResource

# set the player node that corresponds to this PlayerResource
func setPlayerResource(newPlayerResource: PlayerResource):
	# if there is already a player node assigned to this resource
	if _playerResource != null:
		printerr("Assigning a new PlayerResource to a player node that already has a PlayerResource")
	_playerResource = newPlayerResource

# --Private Functions--

