extends Node

# this autoload manages character nodes and character resources

## HOW TO USE CHARACTER MANAGER
## Example: creating a character
## network id to use when creating a character (12345 is just an example id and
## most likely not what you will be using)
#	var networkId: int = 12345
#
## have the character manager create a character using that network id
#	Characters.createCharacter(networkId, name)
#	 > returns a CharacterResource corresponding to the character that was just
#		created


# --Public Variables--

# path to character scene
const CHARACTER_SCENE_PATH: String = "res://game/character/character.tscn"
var characterScene: PackedScene = preload(CHARACTER_SCENE_PATH)

# --Private Variables--

# _characterNodes and _characterResources are private variables because only this 
# 	script should be editing them

# stores character resources keyed by network id
# {<network id>: <character resource>}
var _characterResources: Dictionary = {}

# --Public Functions--

# create a new character for the given network id
# returns the character resource because I think it would be more useful than
# 	the character node - TheSecondReal0
func createCharacter(networkId: int, name: String) -> CharacterResource:
	## Create character resource
	var characterResource: CharacterResource = _createCharacterResource(networkId)
	## Assign character node to resource
	characterResource.createCharacterNode()
	## Register character node and resource
	_registerCharacterResource(networkId, characterResource)
	## Set the name of the character
	characterResource.setCharacterName(name)
	var myId: int = Connections.getMyId()
	## If own character is added
	if networkId == myId:
		## Apply appearance to character
		characterResource.setAppearance(Appearance.currentOutfit, Appearance.currentColors)
		## Send my character data to server
		sendOwnCharacterData()
	## Return character resource
	return characterResource

# create a character node, this function is used when creating a new character
func createCharacterNode(networkId: int = -1) -> CharacterBody2D:
	## instance character scene
	var characterNode: CharacterBody2D = characterScene.instantiate()
	# set its network id
	characterNode.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterNode

# get character node for the input network id
func getCharacterNode(id: int) -> Node:
	return getCharacterResource(id).getNode()

# get character resource for the input network id
func getCharacterResource(id: int) -> CharacterResource:
	# if there is no character node corresponding to this network id
	if not id in _characterResources:
		# throw an error
		printerr("Trying to get a nonexistant character resource with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false) #,"Thre should be no use case when we look for a non-existent character id")
		# if running in release mode, return null
		return null
	return _characterResources[id]
	
func removeCharacterResource(id: int) -> void:
	# if there is no character node corresponding to this network id
	if not id in _characterResources:
		# throw an error
		printerr("Trying to get a nonexistant character resource with network id ", id)
		# crash the game (if running in debug mode) to assist with debugging
		assert(false) #,"Thre should be no use case when we remove a non-existent character id")
		# if running in release mode, return
		return
	_characterResources.erase(id)

func getMyCharacterNode() -> Node:
	var id: int = Connections.getMyId()
	if not id in _characterResources:
		return null
	return getMyCharacterResource().getNode()

func getMyCharacterResource() -> CharacterResource:
	var id: int = Connections.getMyId()
	if not id in _characterResources:
		return null
	return _characterResources[id]

func getCharacterResources() -> Dictionary:
	return _characterResources

func getCharacterKeys() -> Array:
	return _characterResources.keys()

# --Private Functions--

# create a character resource, this function is used when creating a new character
func _createCharacterResource(networkId: int = -1) -> CharacterResource:
	## instance a new CharacterResource object
	var characterResource: CharacterResource = CharacterResource.new()
	# set its network id
	characterResource.networkId = networkId
	# here is where we would set its player name, but that is not implemented yet
	return characterResource

# add a character resource to the characterResources dictionary
func _registerCharacterResource(id: int, characterResource: CharacterResource) -> void:
	# if there is already a character node for this network id
	if id in _characterResources:
		# throw an error
		printerr("Registering a character resource that already exists, network id: ", id)
		assert(false) #,"Should be unreachable")
	## Register character resource for id
	_characterResources[id] = characterResource

# ----------- PLAYER DATA SYNCING-----------

# --Universal Functions--

## --Client functions

func requestCharacterCustomizations() -> void:
	## Call server to send all character data
	sendAllCharacterCustomizations.rpc_id(1)

func sendOwnCharacterData() -> void:
	var id: int = Connections.getMyId()
	## Get own character resource
	var characterRes: CharacterResource
	characterRes = Characters.getCharacterResource(id)
	## Save data to be sent to the server
	Connections.queueDataToSend("outfit", characterRes.getOutfit(), -1)
	Connections.queueDataToSend("colors", characterRes.getColors(), -1)

## --Server Functions--
@rpc("any_peer", "call_remote", "reliable", 0)
func sendAllCharacterCustomizations() -> void:
	## Get all character resourcse
	var characterRes: Dictionary = {}
	characterRes = getCharacterResources()
	var senderId: int = get_tree().get_multiplayer().get_remote_sender_id()
	## For each character
	for player in characterRes:
		## Collect character outfit data
		## and prepare to send back to sender
		var outfit: Dictionary = characterRes[player].getOutfit()
		var colors: Dictionary = characterRes[player].getColors()
		if len(outfit) > 0:
			Connections.queueDataToBroadcast("outfit", outfit, senderId, player)
		if len(colors) > 0:
			Connections.queueDataToBroadcast("colors", colors, senderId, player)
	#print_debug(characterRes)
	#print_debug(broadcastDataQueue)

# update a character's position
func updateCharacterPosition(networkId: int, characterPos: Vector2) -> void:
	#print("updating position of ", networkId, " to ", characterPos)
	## if position is for own character, exit
	if networkId == Connections.getMyId():
		# don't update its position
		return
	## Set the position for character
	getCharacterResource(networkId).setPosition(characterPos)

func gatherCharacterPositions() -> Dictionary:
	var positions: Dictionary = {}
	for characterId in _characterResources:
		positions[characterId] = _characterResources[characterId].getPosition()
	return positions

# --Client Functions

# send the position if this client's character to the server

