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

# PLACEHOLDER variable storing the role of this character
# not sure what type this variable will be, string is PLACEHOLDER
var _role: String

# the dictionary (?) that stores the tasks assigned to this CharacterResource
# this is a placeholder, not sure what this will look like because the
#	task system has not been implemented yet
var _tasks: Dictionary

# the dictionary (?) that stores outfit information
# this is a placeholder, not sure what this will look like because the
# 	outfit system has not been implemented yet
var _outfit: Dictionary

# the speed at which the character moves/how many pixels it can move every frame
var _speed: float = 150

# --Public Functions--

# function called when character is spawned
func spawn():
	# assert false because spawning isn't implemented yet
	assert(false, "Not implemented yet")

# PLACEHOLDER function for killing characters
func kill():
	# assert false because killing is not implemented yet
	assert(false, "Not implemented yet")

# function called to reset the character resource to default settings
# 	probably going to be used mostly between rounds when roles and stuff are
# 	changing
func reset():
	# assert false because resetting is not implemented yet
	assert(false, "Not implemented yet")

# get the character node that corresponds to this CharacterResource
func getCharacterNode() -> Node:
	return _characterNode

# set the character node that corresponds to this CharacterResource
func setCharacterNode(newCharacterNode: Node) -> void:
	# if there is already a character node assigned to this resource
	if _characterNode != null:
		printerr("Assigning a new character node to a CharacterResource that already has one")
		assert(false, "Should be unreachable")
	_characterNode = newCharacterNode

# get the role of this character
# string is PLACEHOLDER
func getRole() -> String:
	# assert false because roles aren't implemented yet
	assert(false, "Not implemented yet")
	return _role

# set the role of this character
# string return type is PLACEHOLDER
func setRole(newRole: String) -> void:
	# assert false because roles aren't implemented yet
	assert(false, "Not implemented yet")
	_role = newRole

# get tasks assigned to this CharacterResource
func getTasks() -> Dictionary:
	# assert false because tasks aren't implemented yet
	assert(false, "Not implemented yet")
	return _tasks

# set tasks assigned to this CharacterResource
func setTasks(newTasks: Dictionary):
	# assert false because tasks aren't implemented yet
	assert(false, "Not implemented yet")
	_tasks = newTasks

# get the outfit information of this character
func getOutfit() -> Dictionary:
	# assert false because outfits aren't implemented yet
	assert(false, "Not implemented yet")
	return _outfit

# set the outfit information of this character
func setOutfit(newOutfit: Dictionary):
	# assert false because outfits aren't implemented yet
	assert(false, "Not implemented yet")
	_outfit = newOutfit

# get the speed of this character
func getSpeed() -> float:
	return _speed

# not sure we would really want to just overwrite speed but I'm putting this
# 	here for constincency
func setSpeed(value: float) -> void:
	_speed = value

# get the direction the character is looking
func getLookDirection() -> int:
	return _characterNode.getLookDirection()

# set the direction the character is looking
func setLookDirection(newLookDirection: int) -> void:
	_characterNode.setLookDirection(newLookDirection)

# get the position of the character
func getPosition() -> Vector2:
	## Get node position
	return _characterNode.getPosition()

# set the position of the character
func setPosition(newPos: Vector2) -> void:
	## Set node position
	_characterNode.setPosition(newPos)

# get the global position of the character
func getGlobalPosition() -> Vector2:
	return _characterNode.getGlobalPosition()

# set the global position of the character
func setGlobalPosition(newPos: Vector2):
	_characterNode.setPosition(newPos)

# --Private Functions--

