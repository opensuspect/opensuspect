extends Node

# --Public Variables--
# file path to item node scene
const ITEM_NODE_SCENE_PATH: String = "res://game/items/item_node/item_node.tscn"
# scene of the item node
var itemNodeScene: PackedScene = preload(ITEM_NODE_SCENE_PATH)

const ITEM_TEMPLATE_FOLDER_PATH: String = "res://game/items/"

# --Private Variables--
# dictionary storing all item templates keyed by item name
var _itemTemplates: Dictionary = _instanceItemTemplates()


# --Public Functions--
# creates a new ItemResource from this template
func createItem(itemName: String) -> ItemResource:
	# the item template to use when creating this item
	var itemTemplate: ItemTemplate = getItemTemplate(itemName)
	# initialize a new ItemResource
	var itemResource: ItemResource = _createItemResource()
	# initialize a new ItemNode
	var itemNode: Node = _createItemNode()
	
	# have the item template configure the item resource
	itemTemplate.configureItemResource(itemResource)
	
	# assign item nodes and resources to each other
	itemResource.setItemNode(itemNode)
	itemNode.setItemResource(itemResource)
	
	return itemResource

func getItemTemplate(itemName: String) -> ItemTemplate:
	if not itemName in _itemTemplates:
		assert(false, "Trying to get an item template that doesn't exist")
		return null
	return _itemTemplates[itemName]

# --Private Functions--

func _createItemResource() -> ItemResource:
	# initialize a new ItemResource
	var itemResource: ItemResource = ItemResource.new()
	
	# placeholder space to put whatever we need to do to initialize a general item resource
	
	return itemResource

func _createItemNode() -> Node:
	var itemNode: Node = itemNodeScene.instance()
	
	# placeholder space to put whatever we need to do to initialize a general item node
	
	return itemNode

# loads all item templates and returns a dictionary of them keyed by itemName
func _instanceItemTemplates() -> Dictionary:
	var itemTemplateDict: Dictionary = {}
	var templates: Array = Helpers.load_files_in_dir_with_exts(ITEM_TEMPLATE_FOLDER_PATH, [".tres", ".res"])
	
	for template in templates:
		# if the loaded resource is not an item template, ignore it
		if not template is ItemTemplate:
			continue
		# add this item template to the dictionary
		itemTemplateDict[template.itemName] = template
	
	return itemTemplateDict
