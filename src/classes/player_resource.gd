extends Resource
class_name PlayerResource

# the purpose of this class is to serve as the backend for the player object
# each player node will have a corresponding PlayerResource, which stores important
# 	info such as player state, position, tasks, etc.
# PlayerResource objects are kept track of in the Players autoload

# --Public Variables--

# network id corresponding to this player
var networkId: int

# the name of this player
var playerName: String

# --Private Variables--

# the player node corresponding to this PlayerResource
var _playerNode: Node

# the dictionary (?) that stores the tasks assigned to this PlayerResource
# this is a placeholder, not sure what this will look like because the
#	task system has not been implemented yet
var _tasks: Dictionary

# the dictionary (?) that stores outfit information
# this is a placeholder, not sure what this will look like because the
# 	outfit system has not been implemented yet
var _outfit: Dictionary

# --Public Functions--

# get tasks assigned to this PlayerResource
func getTasks() -> Dictionary:
	return _tasks

# get the outfit information of this player
func getOutfit() -> Dictionary:
	return _outfit

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

