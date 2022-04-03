extends Control

onready var gameStartButton: Button = $GameStart
onready var abilityBox: HBoxContainer = $GameUI/Abilities

# Called when the node enters the scene tree for the first time.
func _ready():
	if Connections.isServer():
		showStartButton()
	else:
		showStartButton(false)
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
	var newButton = Button.new()
	newButton.text = buttontext
	abilityBox.add_child(newButton)
	abilityResource.setAbilityHudNode(newButton)
	newButton.connect("button_down", abilityResource, "abilityActivate")

func clearAbilities() -> void:
	for element in abilityBox.get_children():
		element.queue_free()
