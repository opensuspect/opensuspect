extends Node

# this autoload manages character nodes and character resources

## HOW TO USE CHARACTER MANAGER
## Example: creating a character
## network id to use when creating a character (12345 is just an example id and
## most likely not what you will be using)
#	var networkId: int = 12345
#
## have the character manager create a character using that network id
#	Characters.createCharacter(networkId)
#	 > returns a CharacterResource corresponding to the character that was just
#		created


# --Public Variables--

# path to character scene
const CHARACTER_SCENE_PATH: String = "res://game/character/character.tscn"
var characterScene: PackedScene = preload(CHARACTER_SCENE_PATH)

# --Private Variables--

# _characterNodes and _characterResources are private variables because only this 
# 	script should be editing them

# stores character nodes keyed by network id
# {<network id>: <character node>}
var _characterNodes: Dictionary = {}

# stores character resources keyed by network id
# {<network id>: <character resource>}
var _characterResources: Dictionary = {}

var _positionSyncsPerSecond: int = 30
var _timeSincePositionSync: float = 0.0

# --Public Functions--

# create a new character for the given network id
# returns the character resource because I think it would be more useful than
# 	the character node - TheSecondReal0
func createCharacter(networkId: int) -> CharacterResource:
	# create character node and resource
	var characterNode: Node = _createCharacterNode(networkId)
	var characterResource: CharacterResource = _createCharacterResource(networkId)
	
	# assign character nodes and resources to each other
	characterNode.setCharacterResource(characterResource)
	characterResource.setCharacterNode(characterNode)
	
	# register character node and resource
	_registerCharacterNode(networkId, characterNode)
	_registerCharacterResource(networkId, characterResource)
	
	#return character resource
	return characterResource

# get character node for the input network id
func getCharacterNode(id: int) -> Node:
	# if there is no character node corresponding to this network id
	if not id in _characterNodes:
		# throw an error
		printerr("Trying to get a nonexistant character node with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false, "Should be unreachable")
		# if running in release mode, return null
		return null
	return _characterNodes[id]

# get character resource for the input network id
func getCharacterResource(id: int) -> CharacterResource:
	# if there is no character node corresponding to this network id
	if not id in _characterResources:
		# throw an error
		printerr("Trying to get a nonexistant character resource with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false, "Should be unreachable")
		# if running in release mode, return null
		return null
	return _characterResources[id]

func getMyCharacterNode() -> Node:
	return _characterNodes[get_tree().get_network_unique_id()]

func getMyCharacterResource() -> CharacterResource:
	return _characterResources[get_tree().get_network_unique_id()]

func getCharacterNodes() -> Dictionary:
	return _characterNodes

func getCharacterResources() -> Dictionary:
	return _characterResources

# --Private Functions--

# create a character node, this function is used when creating a new character
func _createCharacterNode(networkId: int = -1) -> Node:
	## instance character scene
	var characterNode: Node = characterScene.instance()
	# set its network id
	characterNode.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterNode

# create a character resource, this function is used when creating a new character
func _createCharacterResource(networkId: int = -1) -> CharacterResource:
	## instance a new CharacterResource object
	var characterResource: CharacterResource = CharacterResource.new()
	# set its network id
	characterResource.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterResource

# add a character node to the characterNodes dictionary
func _registerCharacterNode(id: int, characterNode: Node) -> void:
	# if there is already a character node for this network id
	if id in _characterNodes:
		# throw an error
		printerr("Registering a character node that already exists, network id: ", id)
		assert(false, "Should be unreachable")
	## Register character node for id
	_characterNodes[id] = characterNode

# add a character resource to the characterResources dictionary
func _registerCharacterResource(id: int, characterResource: CharacterResource) -> void:
	# if there is already a character node for this network id
	if id in _characterResources:
		# throw an error
		printerr("Registering a character resource that already exists, network id: ", id)
		assert(false, "Should be unreachable")
	## Register character resource for id
	_characterResources[id] = characterResource



# -----------MOVEMENT SYNCING-----------

# --Universal Functions--

func _process(delta: float) -> void:
	_timeSincePositionSync += delta
	# if it is not yet time for another position sync
	if _timeSincePositionSync < 1.0 / _positionSyncsPerSecond:
		return
	# reset position sync timer
	_timeSincePositionSync = 0.0
	# if this is a server and a client (aka network authority but also has
	# 	its own character)
	if Connections.isClientServer():
		# send the position of the server's character to all other clients
		rpc("_updateCharacterPosition", 1, getMyCharacterResource().getPosition())
	# otherwise, if this is just a normal client
	elif Connections.isClient():
		_sendMyCharacterPosToServer()

# update a character's position
# puppetsync keyword means that when this function is used in an rpc call
# 	it will be run on both server and client
puppetsync func _updateCharacterPosition(networkId: int, characterPos: Vector2) -> void:
	#print("updating position of ", networkId, " to ", characterPos)
	# if this position is for this client's character
	if networkId == get_tree().get_network_unique_id():
		# don't update its position
		return
	getCharacterResource(networkId).setPosition(characterPos)

# --Server Functions--

# receive a client's position
# master keyword means that this function will only be run on the server when RPCed
master func _receiveCharacterPosFromClient(newPos: Vector2) -> void:
	var sender: int = get_tree().get_rpc_sender_id()
	_updateCharacterPosition(sender, newPos)

# --Client Functions

# send the position if this client's character to the server
func _sendMyCharacterPosToServer() -> void:
	#print("sending my position to server")
	var myPosition: Vector2 = getMyCharacterResource().getPosition()
	rpc_id(1, "_receiveCharacterPosFromClient", myPosition)
