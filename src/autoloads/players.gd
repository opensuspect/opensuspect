extends Node

# this autoload manages player nodes and player resources

# --Public Variables--


# --Private Variables--

# _playerNodes and _playerResources are private variables because only this 
# 	script should be editing them

# stores player nodes keyed by network id
# {<network id>: <player node>}
var _playerNodes: Dictionary = {}

# stores player resources keyed by network id
# {<network id>: <player resource>}
var _playerResources: Dictionary = {}

# --Public Functions--

# add a player node to the playerNodes dictionary
func registerPlayerNode(id: int, playerNode: Node):
	# if there is already a player node for this network id
	if id in _playerNodes:
		# throw an error
		printerr("Registering a player node that already exists, network id: ", id)
	_playerNodes[id] = playerNode

# add a player resource to the playerResources dictionary
func registerPlayerResource(id: int, playerResource: PlayerResource):
	# if there is already a player node for this network id
	if id in _playerNodes:
		# throw an error
		printerr("Registering a player node that already exists, network id: ", id)
	_playerResources[id] = playerResource

# get player node for the input network id
func getPlayerNode(id: int) -> Node:
	# if there is no player node corresponding to this network id
	if not id in _playerNodes:
		# throw an error
		printerr("Trying to get a nonexistant player node with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false)
		# if running in release mode, return null
		return null
	return _playerNodes[id]

# get player resource for the input network id
func getPlayerResource(id: int) -> PlayerResource:
	# if there is no player node corresponding to this network id
	if not id in _playerResources:
		# throw an error
		printerr("Trying to get a nonexistant player resource with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false)
		# if running in release mode, return null
		return null
	return _playerResources[id]

func getPlayerNodes() -> Dictionary:
	return _playerNodes

func getPlayerResources() -> Dictionary:
	return _playerResources

# --Private Functions--

