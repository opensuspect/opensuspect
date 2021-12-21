extends KinematicBody2D

# this script acts as the frontend for the players/controls the player node

# --Public Variables--

# network id corresponding to this player node
var network_id: int


# --Private Variables--

# the PlayerResource corresponding to this player node
var _playerResource: PlayerResource




# --Public Functions--

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

