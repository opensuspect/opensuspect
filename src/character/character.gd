extends KinematicBody2D

# this script acts as the frontend for the characters/controls the character node

# --Public Variables--

# network id corresponding to this character
var networkId: int

# the name of this character
var characterName: String

# --Private Variables--

# the CharacterResource corresponding to this character node
var _characterResource: CharacterResource



# --Public Functions--

# function called when character is spawned
func spawn():
	# assert false because spawning isn't implemented yet
	assert(false)

# PLACEHOLDER function for killing characters
func kill():
	# assert false because killing isn't implemented yet
	assert(false)

# function called to reset the character resource to default settings
# 	probably going to be used mostly between rounds when roles and stuff are
# 	changing
func reset():
	# assert false because resetting is not implemented yet
	assert(false)

# get the character node that corresponds to this CharacterResource
func getCharacterResource() -> CharacterResource:
	return _characterResource

# set the character node that corresponds to this CharacterResource
func setCharacterResource(newCharacterResource: CharacterResource):
	# if there is already a character node assigned to this resource
	if _characterResource != null:
		printerr("Assigning a new CharacterResource to a character node that already has one")
	_characterResource = newCharacterResource

# get the role of this character
# string return type is PLACEHOLDER
func getRole() -> String:
	return _characterResource.getRole()

# get tasks assigned to this character node
func getTasks() -> Dictionary:
	return _characterResource.getTasks()

# get the outfit of the character
func getOutfit() -> Dictionary:
	return _characterResource.getOutfit()

# get the position of the character
func getPosition() -> Vector2:
	return position

# set the position of the character
func setPosition(newPos: Vector2):
	# assert false because setting position (teleporting) is not implemented yet
	assert(false)
	position = newPos

# get the global position of the character
func getGlobalPosition() -> Vector2:
	return global_position

# set the global position of the character
func setGlobalPosition(newPos: Vector2):
	# assert false because setting position (teleporting) is not implemented yet
	assert(false)
	global_position = newPos

# --Private Functions--

