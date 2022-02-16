extends Control

onready var gameStartButton: Button = $GameStart

# Called when the node enters the scene tree for the first time.
func _ready():
	if Connections.isServer():
		showStartButton()
	else:
		showStartButton(false)

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
