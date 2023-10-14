extends Control

onready var gameStartButton: Button = $GameStart
onready var abilityBox: HBoxContainer = $GameUI/Abilities
onready var taskIntBox: HBoxContainer = $GameUI/TaskInteract
onready var itemIntBox: HBoxContainer = $GameUI/ItemInteract
onready var itemUseBox: HBoxContainer = $GameUI/ItemUse
onready var meetingCallBox: HBoxContainer = $GameUI/CallMeeting

var itemPickUpScene: PackedScene = preload("res://game/hud/item_pick_up_button.tscn")
var itemDropScene: PackedScene = preload("res://game/hud/item_drop_button.tscn")
var itemAbilityScene: PackedScene = preload("res://game/hud/item_ability_button.tscn")
var taskInteractScene: PackedScene = preload("res://game/hud/task_interact_button.tscn")

var interactable: Array = []
var interactUi: Array = []
var pickedUp: Array = []
var dropUi: Array = []
var itemUse: Array = []

func _ready() -> void:
	if Connections.isServer():
		showStartButton()
	else:
		showStartButton(false)
	TransitionHandler.gameScene.setHudNode(self)
# warning-ignore:return_value_discarded
	TransitionHandler.gameScene.connect("abilityAssigned", self, "addAbility")
# warning-ignore:return_value_discarded
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

# warning-ignore:unused_argument
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

func refreshItemButtons() -> void:
	var charaterRes: CharacterResource = Characters.getMyCharacterResource()
	var newItemIcon: Control
	for button in dropUi:
		button.queue_free()
	for buttonList in itemUse:
		for button in buttonList:
			button.queue_free()
	dropUi = []
	pickedUp = []
	itemUse = []
	for itemRes in charaterRes.getItems():
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

func itemInteract(itemRes: ItemResource, action: String) -> void:
	if action == "entered":
		addItemToPickUp(itemRes)
	if action == "exited":
		removePickUpItem(itemRes)

func addTaskToInteract(taskRes: TaskResource) -> void:
	var newItemIcon: Control = taskInteractScene.instance()
	newItemIcon.setupButton(taskRes)
	taskIntBox.add_child(newItemIcon)
	interactable.append(taskRes)
	interactUi.append(newItemIcon)

func removeTaskInteract(taskRes: TaskResource) -> void:
	var index: int
	index = interactable.find(taskRes)
	interactUi[index].queue_free()
	interactUi.pop_at(index)
	interactable.pop_at(index)

func taskInteract(taskRes: TaskResource, action: String) -> void:
	if action == "entered":
		addTaskToInteract(taskRes)
	if action == "exited":
		removeTaskInteract(taskRes)

func showMeetingButton(show: bool = true) -> void:
	meetingCallBox.visible = show

func _on_MeetingButton_pressed():
	TransitionHandler.gameScene.callMeeting()
