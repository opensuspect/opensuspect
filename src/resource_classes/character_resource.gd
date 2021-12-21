extends Resource
class_name CharacterResource

# the purpose of this class is to serve as the backend for the character node
# each character node will have a corresponding CharacterResource, which stores
# 	important info such as character state, position, tasks, etc.
# CharacterResource objects are kept track of in the Characters autoload

# --Public Variables--

# network id corresponding to this character
var networkId: int

# the name of this player
var characterName: String

# --Private Variables--

# the character node corresponding to this CharacterResource
var _characterNode: Node

# the dictionary (?) that stores the tasks assigned to this CharacterResource
# this is a placeholder, not sure what this will look like because the
#	task system has not been implemented yet
var _tasks: Dictionary

# the dictionary (?) that stores outfit information
# this is a placeholder, not sure what this will look like because the
# 	outfit system has not been implemented yet
var _outfit: Dictionary

# --Public Functions--

# get tasks assigned to this CharacterResource
func getTasks() -> Dictionary:
	return _tasks

# get the outfit information of this character
func getOutfit() -> Dictionary:
	return _outfit

# get the character node that corresponds to this CharacterResource
func getCharacterNode() -> Node:
	return _characterNode

# set the character node that corresponds to this CharacterResource
func setCharacterNode(newCharacterNode: Node):
	# if there is already a character node assigned to this resource
	if _characterNode != null:
		printerr("Assigning a new character node to a CharacterResource that already has one")
	_characterNode = newCharacterNode

# --Private Functions--

