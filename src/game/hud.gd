extends Control

onready var gameStartButton: Button = $GameStart
onready var abilityBox: HBoxContainer = $GameUI/Abilities
onready var itemIntBox: HBoxContainer = $GameUI/ItemInteract

var interactable: Array = []
var interactUi: Array = []

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

func addItemToPickUp(item: Node) -> void:
	var newItemIcon: TextureButton = TextureButton.new()
	var itemRes: ItemResource = item.getItemResource()
	newItemIcon.texture_normal = itemRes.getHudTexture()
	newItemIcon.rect_scale = itemRes.getHudTextureScale()
	itemIntBox.add_child(newItemIcon)
	interactable.append(item)
	interactUi.append(newItemIcon)

func removePickUpIptem(item: Node) -> void:
	var index: int
	index = interactable.find(item)
	interactUi[index].queue_free()
	interactUi.pop_at(index)
	interactable.pop_at(index)

func itemInteract(item: Node, action: String) -> void:
	if action == "entered":
		addItemToPickUp(item)
	if action == "exited":
		removePickUpIptem(item)
