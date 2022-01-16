extends KinematicBody2D

# this script acts as the frontend for the characters/controls the character node

# --Public Variables--

# network id corresponding to this character
var networkId: int

# the name of this character
var characterName: String

enum LookDirections {LEFT, RIGHT, UP, DOWN}
var lookDirection: int = LookDirections.RIGHT
onready var characterElements = $CharacterElements
onready var skeleton = $CharacterElements/Skeleton

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

# set the outfit of the character
func setAppearance(outfit: Dictionary, colors: Dictionary) -> void:
	var outfitPaths: Dictionary = {}
	for partGroup in outfit: ## For each customizable group
		var selectedLook: String = outfit[partGroup]
		for part in Appearance.groupCustomization[partGroup]: ## For each custom sprite
			var filePath: String = Appearance.customSpritePaths[part][selectedLook]
			outfitPaths[part] = filePath
	
	## Applies appearance to its skeleton
	skeleton.applyAppearance(outfitPaths, colors)

# get the outfit of the character
func getOutfit() -> Dictionary:
	return _characterResource.getOutfit()

# get the position of the character
func getPosition() -> Vector2:
	## Return position
	return position

# set the position of the character
func setPosition(newPos: Vector2) -> void:
	## If movement occured
	if newPos != position:
		## Update look direction based on movement
		setLookDirection(_getLookDirFromVec(newPos - position))
	## Set new position
	position = newPos

# get the global position of the character
func getGlobalPosition() -> Vector2:
	## Return global position
	return global_position

# set the global position of the character
func setGlobalPosition(newPos: Vector2) -> void:
	## update look direction based on movement
	setLookDirection(_getLookDirFromVec(newPos - global_position))
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

# get the direction the character is looking
func getLookDirection() -> int:
	return lookDirection

# set the direction the character is looking
func setLookDirection(newLookDirection: int) -> void:
	lookDirection = newLookDirection
	# very placeholder code just to display the look direction by
	# 	changing where the placeholder triangle is pointing
	# this should eventually be moved into a separate script that handles
	# 	animations and stuff
	# the angle to set the rotation of the triangle to
	var xScale: int = 0
	match lookDirection:
		LookDirections.LEFT:
			xScale = -1
		LookDirections.RIGHT:
			xScale = 1
	if characterElements != null and xScale != 0:
		characterElements.scale.x = xScale

# --Private Functions--

func _process(_delta: float) -> void:
	var amountMoved: Vector2
	## If this character belongs to this client
	if networkId == get_tree().get_network_unique_id():
		## Move character
		amountMoved = _move(_delta)

# move the character based on which keys are pressed and return a vector
# 	describing the movement that occurred
func _move(_delta: float) -> Vector2:
	## Get movement vector based on keypress (not normalized)
	var movementVec: Vector2 = getMovementVector(false)
	# set lookDirection to match the movementVec
	# using the look direction setter here to make it easier to react to
	# 	a changing look direction
	## Sets look direction
	setLookDirection(_getLookDirFromVec(movementVec))
	
	# multiply the movement vec by speed
	movementVec *= _characterResource.getSpeed()
	# move_and_slide() returns the actual motion that happened, store it
	# 	in amountMoved
	## Calculate and execute actual motion
	var amountMoved: Vector2 = move_and_slide(movementVec)
	# return the actual movement that happened
	return amountMoved

func _getLookDirFromVec(vec: Vector2) -> int:
	# this prioritizes looking left and right over up and down (like in
	# 	among us and other games)
	if vec.x == 0 and vec.y == 0:
		return lookDirection
	var newlookDirection: int = LookDirections.RIGHT
	if vec.y < 0:
		newlookDirection = LookDirections.UP
	if vec.y > 0:
		newlookDirection = LookDirections.DOWN
	if vec.x < 0:
		newlookDirection = LookDirections.LEFT
	if vec.x > 0:
		newlookDirection = LookDirections.RIGHT
	return newlookDirection
