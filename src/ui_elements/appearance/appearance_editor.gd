extends Node
# --Private Variables--

onready var tabs: Control  = $MenuMargin/HBoxContainer/TabBox/TabContainer
onready var character: Control = $MenuMargin/HBoxContainer/CharacterBox/CenterCharacter/MenuCharacter
onready var popupCharacter: Control = $SavePopup/MarginContainer/HBoxContainer/MenuCharacter

signal menuBack
signal menuSwitch(menu)

var currentTabId: int # ID of selected tab
var selectedItemId: int # ID of selected item
var itemsList: Dictionary # Dictionary of items, for selection lookup
var tabList: Array # Array of the names of the tabs
var iconList: Dictionary

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
	iconList = Resources.list(icons, Appearance.extensions) # Get a list of all icons
	Appearance.updateConfig() ## Update sample character
	$Darken.hide()
	_generateTabs() ## Generate customization tabs

## Generate the customization menu tabs
func _generateTabs() -> void:
	var representativeSprite: String
	for spriteGroup in Appearance.groupCustomization: ## Iterate over sprite groups
		representativeSprite = Appearance.groupCustomization[spriteGroup][0]
		_addChildTab(representativeSprite) ## Create tab sprite group
	var colorScene = "res://ui_elements/appearance/colors.tscn"
	var colors = load(colorScene).instance()
	colors.connect("setColor", self, "_on_color_selected")
	tabs.add_child(colors) ## Add "Colors" setOutfitPartas a child to tab container

# Add a child tab
func _addChildTab(partName: String) -> void:
	var files = Appearance.customSpritePaths
	assert(not files.empty(), "Empty file list")
	var child = _createChildTab(partName) ## Create a new child tab
	tabs.add_child(child) ## Add the new tab
	tabList.append(partName)
	_populateChildTab(files, partName, child) ## Populate the tab with items

# Create a new child tab
func _createChildTab(resource: String) -> ItemList:
	## Creates and configures a new tab
	var child = ItemList.new() # Create new item list
	child.name = resource.capitalize() # Set the tab's name
	child.max_columns = LIST_COLUMNS # Set the max columns
	child.same_column_width = LIST_SAME_WIDTH # Set the same column width
	child.connect("item_selected", self, "_on_item_selected") ## Connect item selection signal
	return(child) # Return the newly configured child

# Populate the child tab with items
func _populateChildTab(files: Dictionary, resource: String, child: ItemList) -> void:
	itemsList[resource] = [] ## Ready the items list
	assert(not files[resource].empty(), "Empty resource list")
	for item in files[resource]: ## Iterate over the items
		itemsList[resource].append(item) ## Append item to items list dictionary
		var texture = _getTexture(files, resource, item) ## Get texture of icon
		child.add_icon_item(texture) ## Add the icon item with set texture
		child.fixed_icon_size = ITEM_ICON_SIZE ## Configure the icon size

# Update the outfit
func _updateOutfit() -> void:
	var tab = tabs.get_child(currentTabId) ## Get the current tab
	var partName = tabList[currentTabId] ## Get name of current tab
	var selectedItem = itemsList[partName][selectedItemId] ## Get selected resource from item list dictionary
	Appearance.setOutfitPart(selectedItem, partName) ## Set outfit part to correct resource

# Get the texture to use for the item's icon
func _getTexture(directories: Dictionary, namespace: String, resource: String) -> Texture:
	## Gather icons
	
	var icons = iconList[namespace] # Get the icons under the given namespace
	var texturePath: String # Path to the texture
	if icons.has(resource): ## If selected item has icon
		texturePath = iconList[namespace][resource]["path"] # Set item texture to corresponding icon
	else: ## If no icon is present
		assert(false, "The fallback should not be required, assets seem to be missing")
		texturePath = directories[namespace][resource]["path"] ## Use item texture
	var texture = load(texturePath) ## Load texture path as texture
	return(texture) # Return the new texture object

## Save overlay popup
func _savePopup() -> void:
	$Darken.show() ## Darken the screen behind
	$SavePopup.popup_centered() ## Show popup centered on screen
	popupCharacter.setOutline(Color.black) ## Sets outline for character sample

func _deselectItems():
	## Loop through tabs
	for child in tabs.get_children():
		## Unselect all
		if child is ItemList:
			child.unselect_all()

# --Signal Functions--

# Sets the current tab when a tab is changed
func _on_tab_changed(tabId: int) -> void:
	currentTabId = tabId ## Saves current tab position

# Sets the current item when an item is selected
func _on_item_selected(itemId: int) -> void:
	selectedItemId = itemId
	Appearance.customOutfit = true ## Set customOutfit to [TRUE] in appearance.gd
	_updateOutfit() ## Updates outfit on sample character

# Sets the color when selected from the picker
func _on_color_selected(shader, colorMap, position) -> void:
	Appearance.customOutfit = true
	Appearance.setColorFromPos(shader, colorMap, position) ## Set color from position

# Handles randomization of the character
func _on_Random_pressed() -> void:
	## If customOutfit [TRUE] in appearance.gd
	if Appearance.customOutfit:
		$RandomConfirm.popup_centered() ## Show confirmation popup
	else: ## If customOutfit [FALSE] in appearance.gd
		_deselectItems()
		Appearance.randomizeConfig() ## Randomize character appearance

# Switches back to the previous menu
func _on_Back_pressed() -> void:
	emit_signal("menuBack") ## Signal menuBack

# Open the save popup
func _on_Save_pressed() -> void:
	_savePopup() ## Show save popup

# Switch to closet scene
func _on_Closet_pressed() -> void:
	emit_signal("menuSwitch", "closet") ## Signal menuSwitch to closet

# Hide darkener on save popup close
func _on_Popup_hide() -> void:
	$Darken.hide()

# Close the save popup
func _on_Cancel_pressed() -> void:
	$SavePopup.hide()
	$RandomConfirm.hide()

func _on_Character_mouse_entered() -> void:
	character.setOutline(Color("#DB2921")) ## Outline to red

func _on_Character_mouse_exited() -> void:
	character.setOutline(Color("#E6E2DD")) ## Outline to yellow

func _on_Confirm_pressed():
	$RandomConfirm.hide() ## Hide confirmation popup
	Appearance.randomizeConfig() ## Randomize appearance
