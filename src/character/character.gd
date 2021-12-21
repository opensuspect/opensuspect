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

# get tasks assigned to this character node
func getTasks() -> Dictionary:
	return _characterResource.getTasks()

func getOutfit() -> Dictionary:
	return _characterResource.getOutfit()

# get the character node that corresponds to this CharacterResource
func getCharacterResource() -> CharacterResource:
	return _characterResource

# set the character node that corresponds to this CharacterResource
func setCharacterResource(newCharacterResource: CharacterResource):
	# if there is already a character node assigned to this resource
	if _characterResource != null:
		printerr("Assigning a new CharacterResource to a character node that already has one")
	_characterResource = newCharacterResource

# --Private Functions--

