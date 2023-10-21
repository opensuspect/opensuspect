extends Node2D

onready var doorOpened: Node = $DoorOpened
onready var doorClosed: Node = $DoorClosed

func doorClose() -> void:
	doorClosed.visible = true
	doorOpened.visible = false

func doorOpen() -> void:
	doorClosed.visible = false
	doorOpened.visible = true
