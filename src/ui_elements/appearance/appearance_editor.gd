extends Node
# --Private Variables--

onready var tabs = $MenuMargin/HBoxContainer/TabBox/TabContainer
onready var character = $MenuMargin/HBoxContainer/CharacterBox/CenterCharacter/MenuCharacter
onready var popupCharacter = $SavePopup/MarginContainer/HBoxContainer/MenuCharacter

signal menuBack
signal menuSwitch(menu)

var currentTab: int # ID of selected tab
var selectedItem: int # ID of selected item
var itemsList: Dictionary # Dictionary of items, for selection lookup

# Directories of icons
var icons: Dictionary = {
	"Body": "res://game/character/assets/icons/body",
	"Clothes": "res://game/character/assets/icons/clothes",
	"Mouth": "res://game/character/assets/icons/mouth",
	"Face Wear": "res://game/character/assets/icons/face_wear",
	"Facial Hair": "res://game/character/assets/icons/facial_hair",
	"Hat/Hair": "res://game/character/assets/icons/hat_hair",
}

# --Configuration Variables--

# Item list config variables
const LIST_COLUMNS = 0 # Max columns
const LIST_SAME_WIDTH = true # Same column width
const ITEM_ICON_SIZE = Vector2(256, 256) # Icon size of items

# --Private Functions--

func _ready() -> void:
	Appearance.updateConfig()
	$Darken.hide()
	_generateTabs()

## Generate the customization menu tabs
func _generateTabs() -> void:
	var files = Resources.list(Appearance.directories, Appearance.extensions) ## Get file list
	for resource in files.keys(): # Iterate over files
		for namespace in Appearance.groupClothing: # Iterate over the clothing groups
			## Check if resource is a child eg. Left Arm to Clothes
			if Appearance.groupClothing[namespace].has(resource):
				pass
			else:
				_addChildTab(files, resource) ## Otherwise add the tab for this resource
	var colorScene = "res://ui_elements/appearance/colors.tscn"
	var colors = load(colorScene).instance()
	colors.connect("setColor", self, "_on_color_selected")
	tabs.add_child(colors) # Add "Colors" as a child to tab container

# Add a child tab
func _addChildTab(files: Dictionary, resource: String) -> void:
	var child = _createChildTab(resource) # Create a new child tab
	tabs.add_child(child) # Add the new tab
	_populateChildTab(files, resource, child) # Populate the tab with items

# Create a new child tab
func _createChildTab(resource: String) -> ItemList:
	var child = ItemList.new() # Create new item list
	child.name = resource.capitalize() # Set the tab's name
	child.max_columns = LIST_COLUMNS # Set the max columns
	child.same_column_width = LIST_SAME_WIDTH # Set the same column width
	child.connect("item_selected", self, "_on_item_selected") # Link up the item selection signal
	return(child) # Return the newly configured child

# Populate the child tab with items
func _populateChildTab(files: Dictionary, resource: String, child: ItemList) -> void:
	itemsList[resource] = [] # Ready the items list
	for item in files[resource]: # Iterate over the items
		itemsList[resource].append(item) # Append item to the items list dictionary
		var texture = _getTexture(files, resource, item) # Get the texture of the icon
		child.add_icon_item(texture) # Add the icon item with the set texture
		child.fixed_icon_size = ITEM_ICON_SIZE # Configure the icon size

# Update the outfit
func _updateOutfit() -> void:
	var tab = tabs.get_child(currentTab) # Get the current tab
	var namespace = itemsList.keys()[currentTab] # Get the namespace from the item list dictionary
	var resource = itemsList[namespace][selectedItem] # Get the selected resource from the item list dictionary
	Appearance.setOutfitPart(resource, namespace) # Set the outfit part to the correct resource

# Get the texture to use for the item's icon
func _getTexture(directories: Dictionary, namespace: String, resource: String) -> Texture:
	var iconList = Resources.list(icons, Appearance.extensions) # Get a list of all icons
	var icons = iconList[namespace] # Get the icons under the given namespace
	var texturePath: String # Path to the texture
	if icons.has(resource): # Check if the item has an icon
		texturePath = iconList[namespace][resource] # Set the item's texture to the corresponding icon
	else:
		texturePath = directories[namespace][resource] # Otherwise just use the item's texture
	var texture = load(texturePath) # Load the texture path as a texture
	return(texture) # Return the new texture object

## Save overlay popup
func _savePopup() -> void:
	$Darken.show() ## Darken the screen behind
	$SavePopup.popup_centered() # Show the popup centered on the screen
	popupCharacter.setOutline(Color.black)

func _deselectItems():
	for child in tabs.get_children():
		if child is ItemList:
			child.unselect_all()

# --Signal Functions--

# Sets the current tab when a tab is changed
func _on_tab_changed(tab: int) -> void:
	currentTab = tab

# Sets the current item when an item is selected
func _on_item_selected(item: int) -> void:
	selectedItem = item
	Appearance.customOutfit = true
	_updateOutfit() # Updates the outfit of the character

# Sets the color when selected from the picker
func _on_color_selected(shader, colorMap, position) -> void:
	Appearance.customOutfit = true
	Appearance.setColorFromPos(shader, colorMap, position)

# Handles randomization of the character
func _on_Random_pressed() -> void:
	if Appearance.customOutfit:
		$RandomConfirm.popup_centered()
	else:
		_deselectItems()
		Appearance.randomizeConfig() # Randomize the config of the character

# Switches back to the previous menu
func _on_Back_pressed() -> void:
	emit_signal("menuBack")

# Open the save popup
func _on_Save_pressed() -> void:
	_savePopup()

# Switch to closet scene
func _on_Closet_pressed() -> void:
	emit_signal("menuSwitch", "closet")

# Hide darkener on save popup close
func _on_Popup_hide() -> void:
	$Darken.hide()

# Close the save popup
func _on_Cancel_pressed() -> void:
	$SavePopup.hide()
	$RandomConfirm.hide()

func _on_Character_mouse_entered() -> void:
	character.setOutline(Color("#DB2921"))

func _on_Character_mouse_exited() -> void:
	character.setOutline(Color("#E6E2DD"))

func _on_Confirm_pressed():
	$RandomConfirm.hide()
	Appearance.randomizeConfig()
