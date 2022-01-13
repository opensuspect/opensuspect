extends Control

onready var iconCharacter = preload("res://ui_elements/icon_character.tscn")

onready var character = $MenuMargin/HBoxContainer/CharacterBox/CenterCharacter/MenuCharacter
onready var items = $MenuMargin/HBoxContainer/ClosetBox/Panel/ItemList

var configData: Dictionary
var configList: Array

var selectedOutfit: Dictionary
var selectedColors: Dictionary

const NAMESPACE = "appearance"

# Item list config variables
const LIST_COLUMNS = 0 # Max columns
const LIST_SAME_WIDTH = true # Same column width
const ITEM_ICON_SIZE = Vector2(256, 256) # Icon size of items

func listItems() -> void:
	if GameData.exists(NAMESPACE):
		configData = GameData.read(NAMESPACE)
		_populateItems()

# --Private Functions--

func _ready() -> void:
	Appearance.applyConfig()
	_configureItemList()
	listItems()

func _configureItemList():
	items.max_columns = LIST_COLUMNS # Set the max columns
	items.same_column_width = LIST_SAME_WIDTH # Set the same column width
	items.fixed_icon_size = ITEM_ICON_SIZE # Configure the icon size


func _populateItems() -> void:
	for config in configData:
		configList.append(config)
		var texture = _getIconTexture(config)
		items.add_icon_item(texture)

func _getIconTexture(namespace) -> Texture:
	_selectConfig(namespace)
	var iconInstance = iconCharacter.instance()
	self.add_child(iconInstance)
	iconInstance.hide()
	iconInstance.applyConfig(selectedOutfit, selectedColors)
	var texture = iconInstance.texture
	return(texture)

func _selectConfig(namespace: String) -> void:
	var config = configData[namespace]
	selectedOutfit = config["Outfit"]
	selectedColors = config["Colors"]

# --Signal Functions--

func _on_Back_pressed() -> void:
	Scenes.back()

func _on_Select_pressed() -> void:
	Appearance.setConfig(selectedOutfit, selectedColors)
	Scenes.back()

func _on_item_selected(index) -> void:
	var namespace = configList[index]
	_selectConfig(namespace)
	character.setConfig(selectedOutfit, selectedColors)
