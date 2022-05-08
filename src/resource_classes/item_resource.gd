extends Resource
class_name ItemResource

# --Public Variables--
# the name of the item (for ex. "Wrench")
var itemName: String setget setName, getName
# the random id of the item
var itemId: int = -1 setget setId, getId
# the texture used by the item
var texture: Texture = null
# scale to be applied to the texture
var textureScale: Vector2 = Vector2(1, 1)
# the texture and scale used on the HUD for the item
var hudTexture: Texture = null
var hudTextureScale: Vector2 = Vector2(1, 1)
# the texture, scale and rotatation used when picked up
var pickUpTexture: Texture = null
var pickUpTextureScale: Vector2 = Vector2(1, 1)
var pickUpRotation: float = 0

# --Private Variables--
# the item node corresponding to this resource
var _itemNode: Node
# the player resource holding this item
var _holder: CharacterResource = null
# an array with the names of the abilities assigned to this item
# (for the base item resource, there is no special ability though, these
# functions are strictly placeholders for items inheriting this resource)
var _abilities: Array = []
# an array with the icons (textures) for the abilities
var _abilityIcons: Dictionary = {}

# --Public Functions--

# returns the name of this item (for ex. "Wrench")
func getName() -> String:
	return itemName

func setName(newName: String) -> void:
	itemName = newName

func getId() -> int:
	return itemId

func setId(newId: int) -> void:
	if itemId != -1:
		assert(false, "Shouldn't change item ID ever.")
	itemId = newId

func getTexture() -> Texture:
	if _holder == null:
		return texture
	else:
		return pickUpTexture

func getTextureScale() -> Vector2:
	if _holder == null:
		return textureScale
	else:
		return pickUpTextureScale

func getRotationDegrees() -> float:
	if _holder == null:
		return 0.0
	else:
		return pickUpRotation

func getHudTexture() -> Texture:
	return hudTexture

func getHudTextureScale() -> Vector2:
	return hudTextureScale

func setItemNode(newItemNode: Node):
	if _itemNode != null:
		assert(false, "Assigning an item node to an item resource that already has one")
	_itemNode = newItemNode

# returns the item node corresponding to this item resource
func getItemNode() -> Node:
	return _itemNode

# returns which character resource is holding this item (null if dropped)
func getHolder() -> CharacterResource:
	return _holder

# returns whether or not the item is dropped
func isDropped() -> bool:
	return _holder == null

func canBePickedUp(characterRes: CharacterResource) -> bool:
	var characterNode: KinematicBody2D = characterRes.getCharacterNode()
	if _holder != null:
		return false
	if not _itemNode in characterNode.itemPickupArea.get_overlapping_bodies():
		return false
	return true

func canBeDropped(characterRes: CharacterResource) -> bool:
	return true

func attemptPickUp() -> void:
	TransitionHandler.gameScene.itemPickUpAttempt(itemId)

func pickedUp(characterRes: CharacterResource) -> void:
	_holder = characterRes
	_itemNode.setSprite()

func attemptDrop() -> void:
	TransitionHandler.gameScene.itemDropAttempt(itemId)

func droppedDown() -> void:
	_holder = null
	_itemNode.setSprite()

func itemAbilities() -> Array:
	return _abilities

func abilityActivateIcon(abilityName: String) -> Texture:
	return _abilityIcons[abilityName]

func canBeActivated(abilityName: String, properties: Dictionary) -> bool:
	return false

# Placeholder function for inherited items which have abilities
func attemptActivate(abilityName: String) -> void:
	pass

# Placeholder function for inherited items which have abilities
func activate(abilityName: String, properties: Dictionary) -> void:
	pass

# This function should be called whenever the item is removed from the scene.
func remove():
	if _holder != null:
		_holder.dropItem(self)
	_itemNode.queue_free()
