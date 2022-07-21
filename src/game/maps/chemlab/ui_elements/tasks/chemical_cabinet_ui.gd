extends "res://game/ui_elements/task_ui_base.gd"

onready var leftHandle: Node = $Control/DoorClosed/HandleLeft
onready var rightHandle: Node = $Control/DoorClosed/HandleRight
onready var doorOpened: Node = $Control/DoorOpened
onready var doorClosed: Node = $Control/DoorClosed
onready var handle_maxy: int = leftHandle.position.y
onready var handle_miny: int = leftHandle.position.y - 50

var left_in: bool = false
var left_grab: bool = false
var right_in: bool = false
var right_grab: bool = false
var prev_mouse_coord: Vector2
var maxrot = PI/3

func attachNewResource(newRes: Resource) -> void:
	var newState: Dictionary = newRes.activateUi(self)
	doorClosed.visible = not newState["door"]
	doorOpened.visible = newState["door"]
	leftHandle.position.y = handle_maxy - newState["left handle pos"]
	leftHandle.rotation = newState["left handle rot"]
	rightHandle.position.y = handle_maxy - newState["right handle pos"]
	rightHandle.rotation = newState["right handle rot"]

func _on_HandleLeft_mouse_entered() -> void:
	left_in = true

func _on_HandleRight_mouse_entered() -> void:
	right_in = true

func _on_HandleLeft_mouse_exited() -> void:
	left_in = false
	left_grab = false
	var newState: Dictionary = {}
	newState["left handle pos"] = handle_maxy - leftHandle.position.y
	newState["left handle rot"] = leftHandle.rotation
	emit_signal("stateChanged", newState)

func _on_HandleRight_mouse_exited() -> void:
	right_in = false
	right_grab = false
	var newState: Dictionary = {}
	newState["right handle pos"] = handle_maxy - rightHandle.position.y
	newState["right handle rot"] = rightHandle.rotation
	emit_signal("stateChanged", newState)

func doorChange(status: bool) -> void:
	if status:
		doorOpen()
	else:
		doorClose()

func doorClose() -> void:
	doorClosed.visible = true
	doorOpened.visible = false
	emit_signal("stateChanged", {"door": false})

func doorOpen() -> void:
	doorClosed.visible = false
	doorOpened.visible = true
	var newState: Dictionary =  {}
	newState["door"] = true
	newState["left handle pos"] = handle_maxy - leftHandle.position.y
	newState["left handle rot"] = leftHandle.rotation
	newState["right handle pos"] = handle_maxy - rightHandle.position.y
	newState["right handle rot"] = rightHandle.rotation
	emit_signal("stateChanged", newState)

func doorHandleCheck() -> void:
	if rightHandle.rotation <= -maxrot * 0.9 and leftHandle.rotation >= maxrot * 0.9:
		doorOpen()

func handleMove(event, handle_node: Node2D, left_side: bool) -> void:
	var movement: Vector2
	movement = event.position - prev_mouse_coord
	if handle_node.rotation <= 0.02 and handle_node.rotation >= -0.02:
		handle_node.position.y += movement.y
	handle_node.position.y = max(handle_node.position.y, handle_miny)
	handle_node.position.y = min(handle_node.position.y, handle_maxy)
	if handle_node.position.y == handle_miny:
		var posdiff: Vector2
		posdiff = event.position - handle_node.global_position
		if left_side:
			handle_node.rotation = min(posdiff.angle() - PI / 2, maxrot)
			handle_node.rotation = max(handle_node.rotation, 0)
		else:
			handle_node.rotation = max(posdiff.angle() - PI / 2, -maxrot)
			handle_node.rotation = min(handle_node.rotation, 0)
	prev_mouse_coord = event.position
	doorHandleCheck()

func _on_HandleLeft_input_event(viewport, event, shape_idx) -> void:
	if (event is InputEventMouseButton && event.pressed):
		left_grab = true
		prev_mouse_coord = event.position
	elif left_grab:
		handleMove(event, leftHandle, true)

func _on_HandleRight_input_event(viewport, event, shape_idx) -> void:
	if (event is InputEventMouseButton && event.pressed):
		right_grab = true
		prev_mouse_coord = event.position
	elif right_grab:
		handleMove(event, rightHandle, false)
