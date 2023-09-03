extends Node

## HOW TO USE ITEMS AUTOLOAD
## Creating an item
## Figure out the name of the item you want (for ex. "Wrench")
# var itemName: String = "Wrench"
## Create the item
# var itemResource: ItemResource = Items.createItem(itemName)
# var itemNode: Node = itemResource.getItemNode()
## use this however you want, probably adding it to the map or using with a task

## HOW THE ITEMS AUTOLOAD WORKS
## ITEM TEMPLATES
# All item templates are stored in a folder as .tres files
# 	The folder path is stored in ITEM_TEMPLATE_FOLDER_PATH
# When the game starts, all .tres files in that folder are loaded and saved
# 	into the _itemTemplates dictionary, keyed by their itemName variable

## EXAMPLE
# for this example, we will use a theoretical .tres file to walk through the process
# let's say the ItemTemplate resource is saved as wrench.tres
# let's also say the resource looks something like this:

#	wrench.tres
#		itemName = "Wrench"
#		texture = <any texture resource>
#		textureScale = Vector2(1, 1)

# All resources stored in that folder are loaded using these steps:
# 1. _instanceItemTemplates() is called in the declaration of _itemTemplates,
#  		this function returns a dictionary containing all item template resources
# 2. This function starts by using a helper function to instance all resource files
#  		inside the item template folder
# 3. The function then iterates through all of these resources
# 	3a. Makes sure the loaded resource is actually an ItemTemplate, skips that
# 		resource if it is not an ItemTemplate
# 	3b. Gets the itemName from the ItemTemplate (itemTemplate.itemName)
# 	3c. Stores the resource into a dictionary using this itemName as the key

# so by the end of this, the dictionary looks like:
# {"Wrench": <wrench ItemTemplate resource>}

# if there were more item templates in that folder, they would also exist in this
# 	dictionary, looking something like this:

#  {"Wrench": <wrench ItemTemplate resource>,
#	"Flask": <flask ItemTemplate resource,
#	"Battery": <battery ItemTemplate resource}

## Item templates are then used when Items.createItem() is called
# For instance: the wrench item template is used when Items.createItem("Wrench") is called
# The item template is then just used to configure a fresh ItemResource, which is
# 	basically just telling it what name, texture, texture scale, etc. to use



## DEVELOPER NOTES
# We might want to move away from using strings to differentiate between items as
# 	they are somewhat clunky

# --Public Variables--
const ITEM_TEMPLATE_FOLDER_PATH: String = "res://game/items/"

# --Private Variables--
# dictionary storing all item templates keyed by item name
var _itemTemplates: Dictionary = _instanceItemTemplates()

var _items: Dictionary = {}

# --Public Functions--
func getItemTemplate(itemName: String) -> ItemTemplate:
	if not itemName in _itemTemplates:
		assert(false, "Trying to get an item template that doesn't exist")
		return null
	return _itemTemplates[itemName]

func getItemNode(itemId) -> KinematicBody2D:
	return _items[itemId].getItemNode()

func getItemResource(itemId) -> ItemResource:
	return _items[itemId]

func removeItem(itemId: int) -> void:
# warning-ignore:unused_variable
	var itemNode: KinematicBody2D
	_items[itemId].remove()
# warning-ignore:return_value_discarded
	_items.erase(itemId)

func clearItems() -> void:
	var itemIds: Array = _items.keys()
	for itemId in itemIds:
		removeItem(itemId)

# --Server Functions--
func createItemServer(itemName: String, itemPosition: Vector2, properties: Dictionary = {}):
	var newId: int = -1
	while newId == -1 or newId in _items.keys():
		newId = randi()
	rpc("createItemClient", itemName, itemPosition, newId, properties)

func createTaskItemServer(itemName: String, taskName: String, position: String, properties: Dictionary = {}):
	var newId: int = -1
	while newId == -1 or newId in _items.keys():
		newId = randi()
	rpc("createTaskItemClient", itemName, taskName, position, newId, properties)

# --Client functions--
puppetsync func createItemClient(itemName: String, itemPosition: Vector2, newId: int, properties: Dictionary):
	_createItem(itemName, itemPosition, newId, properties)

puppetsync func createTaskItemClient(itemName: String, taskName: String, position: String, newId: int, properties: Dictionary):
	_createTaskItem(itemName, taskName, position, newId, properties)

# --Private Functions--
# creates a new ItemResource from this template
func _createItem(itemName: String, itemPosition: Vector2, newId: int, properties: Dictionary):
	# the item template to use when creating this item
	var itemTemplate: ItemTemplate = getItemTemplate(itemName)
	# initialize a new ItemResource
	var itemResource: ItemResource = itemTemplate.createItemResource(properties)
	itemResource.setTemplate(itemTemplate)
	itemResource.itemId = newId
	_items[newId] = itemResource
	# have the item template configure the item resource
	itemTemplate.configureItemResource(itemResource)
	# initialize a new ItemNode
	itemResource.createItemNode()
	var itemNode: KinematicBody2D = itemResource.getItemNode()
	itemNode.position = itemPosition
	TransitionHandler.gameScene.itemsNode.add_child(itemNode)

func _createTaskItem(itemName: String, taskName: String, position: String, newId: int, properties: Dictionary):
	# the item template to use when creating this item
	var itemTemplate: ItemTemplate = getItemTemplate(itemName)
	# initialize a new ItemResource
	var itemResource: ItemResource = itemTemplate.createItemResource(properties)
	itemResource.setTemplate(itemTemplate)
	itemResource.itemId = newId
	_items[newId] = itemResource
	itemTemplate.configureItemResource(itemResource)
	# get the relevant task resource
	var taskHandler = TransitionHandler.gameScene.taskHandler
	var taskRes: TaskResource = taskHandler.taskResources[taskName]
	## Attach the task to the item and the item to the task
	itemResource.putInTask(taskRes)
	taskRes.addItem(itemResource, position)

# loads all item templates and returns a dictionary of them keyed by itemName
func _instanceItemTemplates() -> Dictionary:
	var itemTemplateDict: Dictionary = {}
	var templateFiles: Dictionary = Resources.listDirectory(ITEM_TEMPLATE_FOLDER_PATH, ["tres", "res"])

	for templateFile in templateFiles.values():
		var template: Resource = load(templateFile["path"])
		# if the loaded resource is not an item template, ignore it
		if not template is ItemTemplate:
			continue
		# get the item name from the ItemTemplate resource
		var itemName: String = template.itemName
		# add this item template to the dictionary
		itemTemplateDict[itemName] = template
	
	return itemTemplateDict
