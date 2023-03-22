extends Control

onready var iconCharacter: Resource = preload("res://ui_elements/icon_character.tscn")

onready var character: Control = $MenuMargin/HBoxContainer/CharacterBox/CenterCharacter/MenuCharacter
onready var items: ItemList = $MenuMargin/HBoxContainer/ClosetBox/Panel/ItemList

onready var selectButton: Control = $MenuMargin/HBoxContainer/CharacterBox/ButtonMargin/Buttons/Select
onready var deleteButton: Control = $MenuMargin/HBoxContainer/CharacterBox/ButtonMargin/Buttons/Delete
onready var nameLabel: Control = $MenuMargin/HBoxContainer/CharacterBox/ButtonMargin/Buttons/Label
onready var infoMessage: CenterContainer = $MenuMargin/HBoxContainer/ClosetBox/Panel/CenterContainer

var configData: Dictionary
var configList: Array

var selectedOutfit: Dictionary
var selectedColors: Dictionary
var selectionName: String

const NAMESPACE = "appearance"

# Item list config variables
const LIST_COLUMNS = 0 # Max columns
const LIST_SAME_WIDTH = true # Same column width
const ITEM_ICON_SIZE = Vector2(256, 256) # Icon size of items

func listItems() -> void:
	## Clear items
	items.clear()
	_clearObjects()
	## If saved data exists
	if GameData.exists(NAMESPACE):
		## Clear everything
		configData.clear()
		configList.clear()
		## Load save data
		configData = GameData.read(NAMESPACE)
		if configData.size() > 0:
			## Hide Info
			infoMessage.hide()
			## Populate UI
			_populateItems()

# --Private Functions--

func _ready() -> void:
	selectButton.disabled = true ## Disable selection button
	deleteButton.disabled = true ## Disable selection button
	Appearance.updateConfig() ## Update sample character
	_configureItemList() ## Configure list of saves
	listItems() ## Show list

# Called from scene switcher whenever this scene is focused
func _focus() -> void:
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
	## For all saved appearances
	for config in configData:
		## Save in list
		configList.append(config)
		## Populate UI
		var texture = _getIconTexture(config)
		items.add_icon_item(texture)
		items.set_item_tooltip(index, config)
		index += 1

func _getIconTexture(namespace) -> Texture:
	## Selects saved config
	_selectConfig(namespace)
	## Creates a character icon
	var iconInstance = iconCharacter.instance()
	self.add_child(iconInstance)
	iconInstance.add_to_group("iconCharacter")
	iconInstance.hide()
	## Sets outfit for character icon
	iconInstance.applyConfig(selectedOutfit, selectedColors)
	## Generates texture from character icon
	var texture = iconInstance.texture
	return(texture)

func _selectConfig(namespace: String) -> void:
	var config = configData[namespace]
	selectedOutfit = config["Outfit"]
	selectedColors = config["Colors"]

func _deleteConfig(name: String) -> bool:
	if not GameData.exists(NAMESPACE):
		return false
	if configData.erase(name):
		GameData.write(NAMESPACE, configData)
		listItems()
		return true
	return false

# --Signal Functions--

func _on_Back_pressed() -> void:
	Scenes.back()

func _on_Select_pressed() -> void:
	## Set appearance
	Appearance.setConfig(selectedOutfit, selectedColors)
	## Set customOutfit to [TRUE] in appearance.gd
	Appearance.customOutfit = true
	Scenes.back()

func _on_item_selected(index) -> void:
	## Selects confg with specific name
	var namespace = configList[index]
	nameLabel.text = namespace
	_selectConfig(namespace)
	## Enables selection button
	selectButton.disabled = false
	deleteButton.disabled = false
	selectionName = namespace
	## Sample character appearance set
	character.setAppearance(selectedOutfit, selectedColors)

func _on_Popup_hide():
	$Darken.hide()

func _on_Delete_pressed():
	$Darken.show()
	$DeleteConfirm.popup_centered()

func _on_Confirm_pressed():
	$DeleteConfirm.hide()
	_deleteConfig(selectionName)
	selectButton.disabled = true
	deleteButton.disabled = true
	listItems()

func _on_Cancel_pressed():
	$DeleteConfirm.hide()
