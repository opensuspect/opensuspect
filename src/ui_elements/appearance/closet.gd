extends Control

onready var iconCharacter = preload("res://ui_elements/icon_character.tscn")

onready var character = $MenuMargin/HBoxContainer/CharacterBox/CenterCharacter/MenuCharacter
onready var items = $MenuMargin/HBoxContainer/ClosetBox/Panel/ItemList

onready var selectButton = $MenuMargin/HBoxContainer/CharacterBox/ButtonMargin/Buttons/Select
onready var nameLabel = $MenuMargin/HBoxContainer/CharacterBox/ButtonMargin/Buttons/Label

signal menuBack

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
	items.clear()
	_clearObjects()
	if GameData.exists(NAMESPACE):
		configData.clear()
		configList.clear()
		items.clear()
		configData = GameData.read(NAMESPACE)
		_populateItems()

# --Private Functions--

func _ready() -> void:
	selectButton.disabled = true
	Appearance.updateConfig()
	_configureItemList()
	listItems()

func _clearObjects():
	for child in get_children():
		if child.is_in_group("iconCharacter"):
			remove_child(child)
			child.remove_from_group("iconCharacter")
			child.queue_free()

func _configureItemList():
	items.max_columns = LIST_COLUMNS # Set the max columns
	items.same_column_width = LIST_SAME_WIDTH # Set the same column width
	items.fixed_icon_size = ITEM_ICON_SIZE # Configure the icon size

func _populateItems() -> void:
	var index: int = 0
	for config in configData:
		configList.append(config)
		var texture = _getIconTexture(config)
		items.add_icon_item(texture)
		items.set_item_tooltip(index, config)
		index += 1

func _getIconTexture(namespace) -> Texture:
	_selectConfig(namespace)
	var iconInstance = iconCharacter.instance()
	self.add_child(iconInstance)
	iconInstance.add_to_group("iconCharacter")
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
	emit_signal("menuBack")

func _on_Select_pressed() -> void:
	Appearance.setConfig(selectedOutfit, selectedColors)
	Appearance.customOutfit = true
	emit_signal("menuBack")

func _on_item_selected(index) -> void:
	var namespace = configList[index]
	nameLabel.text = namespace
	_selectConfig(namespace)
	selectButton.disabled = false
	character.setAppearance(selectedOutfit, selectedColors)
