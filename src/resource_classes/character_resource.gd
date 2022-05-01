extends Resource
class_name CharacterResource

# the purpose of this class is to serve as the backend for the character node
# each character node will have a corresponding CharacterResource, which stores
# 	important info such as character state, position, tasks, etc.
# CharacterResource objects are kept track of in the Characters autoload

# --Public Variables--

# network id corresponding to this character
var networkId: int = -1 setget setNetworkId, getNetworkId

# the name of this player
var characterName: String

var mainCharacter: bool = false
# --Private Variables--

# the character node corresponding to this CharacterResource
var _characterNode: KinematicBody2D

# Names of the apparent team and role of the character. This might not be the
# "Real" role (that is stored on the server)
var _team: String
var _role: String
var _nameColor: Color

# Is the character alive or not
var _alive: bool = true

# List of special abilities
var _abilities: Array = []

# List of items in hand
var _items: Array = []

# the dictionary (?) that stores the tasks assigned to this CharacterResource
# this is a placeholder, not sure what this will look like because the
#	task system has not been implemented yet
var _tasks: Dictionary

# the dictionary (?) that stores outfit information
# this is a placeholder, not sure what this will look like because the
# 	outfit system has not been implemented yet
var _outfit: Dictionary
var _colors: Dictionary

# the speed at which the character moves/how many pixels it can move every frame
var _speed: float = 150

# --Public Functions--

func setNetworkId(newId: int) -> void:
	assert(networkId == -1, "attempting to change networkID on something that has been set")
	networkId = newId

func getNetworkId() -> int:
	return networkId

# function called when character is spawned
func spawn(coords: Vector2):
	_characterNode.spawn()
	setPosition(coords)

func die():
	_characterNode.die()
	_alive = false

func isAlive() -> bool:
	return _alive

# function called to reset the character resource to default settings
# 	probably going to be used mostly between rounds when roles and stuff are
# 	changing
func reset():
	# assert false because resetting is not implemented yet
	assert(false, "Not implemented yet")

# function called when character disconnects from server
func disconnected():
	_characterNode.disconnected()
	_characterNode.queue_free()

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
	if networkId == Connections.getMyId():
		_characterNode.setMainCharacter()
		mainCharacter = true

func resetCharacter() -> void:
	resetAbilities()
	_team = ""
	_role = ""
	_nameColor = Color.white
	_alive = true
	_characterNode.reset()

func getCharacterName() -> String:
	return characterName

func setCharacterName(newName: String) -> void:
	characterName = newName
	_characterNode.setCharacterName(characterName)

# get the Team of this chacter
func getTeam() -> String:
	return _team

# set the role of this character
func setTeam(newTeam: String) -> void:
	_team = newTeam

# get the role of this chacter
func getRole() -> String:
	return _role

# set the role of this character
func setRole(newRole: String) -> void:
	_role = newRole

# set the color of the name for the character
func setNameColor(newColor: Color) -> void:
	_characterNode.setNameColor(newColor)
	_nameColor = newColor

func getNameColor() -> Color:
	return _nameColor

func addAbility(ability: Ability) -> void:
	_abilities.append(ability)
	ability.registerOwner(self)

func resetAbilities() -> void:
	_abilities = []
	_characterNode.clearAbilities()

func getAbilities() -> Array:
	return _abilities

func isAbility(abilityName: String) -> bool:
	for ability in _abilities:
		if ability.getName() == abilityName:
			return true
	return false

func getAbility(abilityName: String) -> Ability:
	for ability in _abilities:
		if ability.getName() == abilityName:
			return ability
	return null

func canPickUpItem(itemRes) -> bool:
	if len(_items) > 0:
		return false
	return itemRes.canBePickedUp(self)

func pickUpItem(itemRes) -> void:
	var itemNode: KinematicBody2D = itemRes.getItemNode()
	if TransitionHandler.gameScene.itemsNode.is_a_parent_of(itemNode):
		TransitionHandler.gameScene.itemsNode.remove_child(itemNode)
	_characterNode.skeleton.putItemInHand(itemNode)
	_items.append(itemRes)
	itemRes.pickedUp(self)

func getItems() -> Array:
	return _items.duplicate()

func canDropItem(itemRes) -> bool:
	if not itemRes in _items:
		return false
	return itemRes.canBeDropped(self)

func dropItem(itemRes):
	var itemNode: KinematicBody2D = itemRes.getItemNode()
	_characterNode.skeleton.removeItemFromHand(itemNode)
	_items.pop_at(_items.find(itemRes))
	itemNode.position = _characterNode.position
	TransitionHandler.gameScene.itemsNode.add_child(itemNode)
	itemRes.droppedDown()

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
	return _outfit

func getColors() -> Dictionary:
	return _colors

# set the outfit information of this character
func setAppearance(newOutfit: Dictionary, newColors: Dictionary) -> void:
	## Set appearance (deferred)
	_outfit = newOutfit
	_colors = newColors
	_characterNode.call_deferred("setAppearance", _outfit, _colors)

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

