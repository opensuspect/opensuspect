extends Control

onready var gamestartButton: Button = $GameStart

# Called when the node enters the scene tree for the first time.
func _ready():
	if Connections.isServer():
		showStartButton()
	else:
		showStartButton(false)

func showStartButton(buttonShow: bool = true) -> void:
	## Switch visibility of game start button
	gamestartButton.visible = buttonShow

func _on_GameStart_pressed() -> void:
	if not Connections.isServer():
		assert(false, "Unreachable")
	## Change the map
	TransitionHandler.changeMap()
	## Change button text
	if TransitionHandler.getCurrentState() == TransitionHandler.States.LOBBY:
		gamestartButton.text = "Start game"
	elif TransitionHandler.getCurrentState() == TransitionHandler.States.MAP:
		gamestartButton.text = "Back to lobby"
	else:
		assert(false, "Unreachable")
