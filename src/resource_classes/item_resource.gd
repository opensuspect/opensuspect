extends Resource
class_name ItemResource

# --Public Variables--
# the name of the item (for ex. "Wrench")
var itemName: String
# the texture used by the item
var texture: Texture = null
# scale to be applied to the texture
var textureScale: Vector2 = Vector2(1, 1)
# the texture and scale used on the HUD for the item
var hudTexture: Texture = null
var hudTextureScale: Vector2 = Vector2(1, 1)

# --Private Variables--
# the item node corresponding to this resource
var _itemNode: Node
# the player resource holding this item
var _holder: CharacterResource
# whether or not this item is dropped
var _dropped: bool


# --Public Functions--

# returns the name of this item (for ex. "Wrench")
func getName() -> String:
	return itemName

func getTexture() -> Texture:
	return texture

func getTextureScale() -> Vector2:
	return textureScale

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
	return _dropped
