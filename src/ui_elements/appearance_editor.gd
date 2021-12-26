extends Node

onready var Resources = get_node("/root/Resources")
onready var Appearance = get_node("/root/Appearance")

onready var tabs = $Menu/HBoxContainer/TabContainer
onready var player = $Menu/HBoxContainer/VBoxContainer/Player/menu_player/Skeleton

var currentTab: int
var selectedItem: int
var itemsList: Dictionary

var icons: Dictionary = {
	"Body": "res://game/character/assets/icons/body",
	"Clothes": "res://game/character/assets/icons/clothes",
	"Mouth": "res://game/character/assets/icons/mouth",
	"Face Wear": "res://game/character/assets/icons/face_wear",
	"Facial Hair": "res://game/character/assets/icons/facial_hair",
	"Hat/Hair": "res://game/character/assets/icons/hat_hair",
}

const LIST_COLUMNS = 0
const LIST_ICON_SIZE = Vector2(256, 256)

# Called when the node enters the scene tree for the first time.
func _ready():
	player.applyConfig()
	_generateTabs()

func _generateTabs() -> void:
	var files = Resources.list(Appearance.directories, Appearance.extensions)
	for file in files.keys():
		for namespace in Appearance.groupClothing:
			if Appearance.groupClothing[namespace].has(file):
				pass
			else:
				_addChild(files, file)
	var colors = VBoxContainer.new()
	colors.name = "Colors"
	tabs.add_child(colors)

func _addChild(files, file):
	var child = _createChild(file)
	tabs.add_child(child)
	itemsList[file] = []
	for item in files[file]:
		itemsList[file].append(item)
		var texture = _getTexture(files, file, item)
		child.add_icon_item(texture)
		child.fixed_icon_size = LIST_ICON_SIZE

func _createChild(file):
	var child = ItemList.new()
	child.name = file.capitalize()
	child.max_columns = LIST_COLUMNS
	child.same_column_width = true
	child.connect("item_selected", self, "_on_item_selected")
	return(child)

func _updateOutfit() -> void:
	var tab = tabs.get_child(currentTab)
	var namespace = itemsList.keys()[currentTab]
	var resource = itemsList[namespace][selectedItem]
	Appearance.setOutfitPart(resource, namespace)
	player.applyConfig()

func _getTexture(directories, namespace, resource) -> Texture:
	var iconList = Resources.list(icons, Appearance.extensions)
	var keys = iconList[namespace]
	var texture_path: String
	if keys.has(resource):
		texture_path = iconList[namespace][resource]
	else:
		texture_path = directories[namespace][resource]
	var texture = load(texture_path)
	return(texture)

func _on_tab_changed(tab):
	currentTab = tab

func _on_item_selected(item):
	selectedItem = item
	_updateOutfit()

func _on_Random_pressed():
	Appearance.randomizeConfig()
	player.applyConfig()
