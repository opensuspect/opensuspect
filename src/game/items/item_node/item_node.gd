extends KinematicBody2D
class_name ItemNode

# --Private Variables--
# the item resource corresponding to this item node
var _itemResource: ItemResource

# --Public Variables--
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
