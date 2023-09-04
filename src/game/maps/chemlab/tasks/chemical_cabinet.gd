extends Node2D

onready var doorOpened: Node = $DoorOpened
onready var doorClosed: Node = $DoorClosed

func doorClose() -> void:
	doorClosed.show()
	doorOpened.hide()

func doorOpen() -> void:
	doorClosed.hide()
	doorOpened.show()
