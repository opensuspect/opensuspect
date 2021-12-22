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
	assert(false, "Not implemented yet")

# PLACEHOLDER function for killing characters
func kill():
	# assert false because killing isn't implemented yet
	assert(false, "Not implemented yet")

# function called to reset the character resource to default settings
# 	probably going to be used mostly between rounds when roles and stuff are
# 	changing
func reset():
	# assert false because resetting is not implemented yet
	assert(false, "Not implemented yet")

# get the character node that corresponds to this CharacterResource
func getCharacterResource() -> CharacterResource:
	return _characterResource

# set the character node that corresponds to this CharacterResource
func setCharacterResource(newCharacterResource: CharacterResource) -> void:
	# if there is already a character node assigned to this resource
	if _characterResource != null:
		printerr("Assigning a new CharacterResource to a character node that already has one")
		assert(false, "Should be unreachable")
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
func setPosition(newPos: Vector2) -> void:
	position = newPos

# get the global position of the character
func getGlobalPosition() -> Vector2:
	return global_position

# set the global position of the character
func setGlobalPosition(newPos: Vector2) -> void:
	global_position = newPos

# get the movement vector by looking at which keys are pressed
func getMovementVector(normalized: bool = true) -> Vector2:
	var vector: Vector2 = Vector2()
	# get the movement vector using the move_left, move_right, move_up, 
	# 	and move_down keys found in the input map
	vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if normalized:
		vector = vector.normalized()
	return vector

# --Private Functions--

func _process(_delta: float) -> void:
	var amountMoved: Vector2 = _move(_delta)

# move the character based on which keys are pressed and return a vector
# 	describing the movement that occurred
func _move(_delta: float) -> Vector2:
	# get the movement vector given which keys are pressed (not normalized)
	var movementVec: Vector2 = getMovementVector(false)
	# multiply the movement vec by speed
	movementVec *= _characterResource.getSpeed()
	# move_and_slide() returns the actual motion that happened, store it
	# 	in amountMoved
	var amountMoved: Vector2 = move_and_slide(movementVec)
	# return the actual movement that happened
	return amountMoved
