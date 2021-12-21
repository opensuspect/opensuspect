extends Resource
class_name PlayerResource

# the purpose of this class is to serve as the backend for the player object
# each player node will have a corresponding PlayerResource, which stores important
# 	info such as player state, position, tasks, etc.
# PlayerResource objects are kept track of in the Players autoload

# --Public Variables--

# network id corresponding to this PlayerResource
var network_id: int


# --Private Variables--

# the player node corresponding to this PlayerResource
var _playerNode: Node




# --Public Functions--

# get the player node that corresponds to this PlayerResource
func getPlayerNode() -> Node:
	return _playerNode

# set the player node that corresponds to this PlayerResource
func setPlayerNode(newPlayerNode: Node):
	# if there is already a player node assigned to this resource
	if _playerNode != null:
		printerr("Assigning a new player node to a PlayerResource that already has a player node")
	_playerNode = newPlayerNode

# --Private Functions--

