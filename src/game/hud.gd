extends Control

onready var gameStartButton: Button = $GameStart
onready var abilityBox: HBoxContainer = $GameUI/Abilities
onready var itemIntBox: HBoxContainer = $GameUI/ItemInteract
onready var itemUseBox: HBoxContainer = $GameUI/ItemUse

var itemPickUpScene: PackedScene = preload("res://game/hud/item_pick_up_button.tscn")
var itemDropScene: PackedScene = preload("res://game/hud/item_drop_button.tscn")
var itemAbilityScene: PackedScene = preload("res://game/hud/item_ability_button.tscn")

var interactable: Array = []
var interactUi: Array = []
var pickedUp: Array = []
var dropUi: Array = []
var itemUse: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if Connections.isServer():
		showStartButton()
	else:
		showStartButton(false)
	TransitionHandler.gameScene.setHudNode(self)
	TransitionHandler.gameScene.connect("abilityAssigned", self, "addAbility")
	TransitionHandler.gameScene.connect("clearAbilities", self, "clearAbilities")

func showStartButton(buttonShow: bool = true) -> void:
	## Switch visibility of game start button
	gameStartButton.visible = buttonShow

func _on_GameStart_pressed() -> void:
	if not Connections.isServer():
		assert(false, "Unreachable")
	## Change the map
	TransitionHandler.changeMap()
	## Change button text
	if TransitionHandler.getCurrentState() == TransitionHandler.States.LOBBY:
		gameStartButton.text = "Start game"
	elif TransitionHandler.getCurrentState() == TransitionHandler.States.ASSIGNMENT:
		gameStartButton.text = "Back to lobby"
	else:
		assert(false, "Unreachable")

func addAbility(buttontext: String, abilityResource: Ability) -> void:
	var newButton: Node = abilityResource.createAbilityHudNode()
	abilityBox.add_child(newButton)

func clearAbilities() -> void:
	for element in abilityBox.get_children():
		element.queue_free()

func addItemToPickUp(itemRes: ItemResource) -> void:
	var newItemIcon: Control = itemPickUpScene.instance()
	newItemIcon.setItemResource(itemRes)
	if Characters.getMyCharacterResource().canPickUpItem(itemRes):
		itemIntBox.add_child(newItemIcon)
	interactable.append(itemRes)
	interactUi.append(newItemIcon)

func removePickUpItem(itemRes: ItemResource) -> void:
	var index: int
	index = interactable.find(itemRes)
	interactUi[index].queue_free()
	interactUi.pop_at(index)
	interactable.pop_at(index)

func hidePickUpButtons() -> void:
	for interactIconInstance in interactUi:
		itemIntBox.remove_child(interactIconInstance)

func refreshPickUpButtons() -> void:
	for buttonInstance in interactUi:
		if itemIntBox.is_a_parent_of(buttonInstance):
			continue
		itemIntBox.add_child(buttonInstance)

func removeItemButton(itemRes: ItemResource) -> void:
	var index: int
	index = pickedUp.find(itemRes)
	dropUi[index].queue_free()
	for itemIcon in itemUse[index]:
		itemIcon.queue_free()
	dropUi.pop_at(index)
	pickedUp.pop_at(index)
	itemUse.pop_at(index)

func refreshItemButtons() -> void:
	var charaterRes: CharacterResource = Characters.getMyCharacterResource()
	var newItemIcon: Control
	for itemRes in charaterRes.getItems():
		if itemRes in pickedUp:
			continue
		newItemIcon = itemDropScene.instance()
		newItemIcon.setItemResource(itemRes)
		itemIntBox.add_child(newItemIcon)
		pickedUp.append(itemRes)
		dropUi.append(newItemIcon)
		var itemAbilityButtons: Array = []
		for abilityName in itemRes.itemAbilities():
			var newAbilityButton: Control
			newAbilityButton = itemAbilityScene.instance()
			newAbilityButton.setupButton(itemRes, abilityName)
			itemUseBox.add_child(newAbilityButton)
			itemAbilityButtons.append(newAbilityButton)
		itemUse.append(itemAbilityButtons)
	for droppable in pickedUp:
		if droppable in charaterRes.getItems():
			continue
		removeItemButton(droppable)

func itemInteract(itemRes: ItemResource, action: String) -> void:
	if action == "entered":
		addItemToPickUp(itemRes)
	if action == "exited":
		removePickUpItem(itemRes)
