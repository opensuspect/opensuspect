extends Resource
class_name ItemResource

# --Public Variables--
var itemName: String

# --Private Variables--
# the item node corresponding to this resource
var _itemNode: ItemNode
# the player resource holding this item
var _holder: CharacterResource
# whether or not this item is dropped
var _dropped: bool


# --Public Functions--
# returns the name of this item (for ex. "Wrench")
func getName() -> String:
	return itemName

# returns the item node corresponding to this item resource
func getItemNode() -> ItemNode:
	return _itemNode

# returns which character resource is holding this item (null if dropped)
func getHolder() -> CharacterResource:
	return _holder

# returns whether or not the item is dropped
func isDropped() -> bool:
	return _dropped
