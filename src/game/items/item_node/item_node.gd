extends KinematicBody2D

# --Private Variables--
# the item resource corresponding to this item node
var _itemResource: ItemResource

# --Public Variables--
func setItemResource(newItemResource: ItemResource):
	if _itemResource != null:
		assert(false, "Assigning an item resource to an item node that already has one")
	_itemResource = newItemResource

# returns the name of this item (for ex. "Wrench")
func getName() -> String:
	return _itemResource.getName()

# returns the item resource corresponding to this item node
func getItemResource() -> ItemResource:
	return _itemResource

# returns which character resource is holding this item (null if dropped)
func getHolder() -> CharacterResource:
	return _itemResource.getHolder()

# returns whether or not the item is dropped
func isDropped() -> bool:
	return _itemResource.isDropped()
