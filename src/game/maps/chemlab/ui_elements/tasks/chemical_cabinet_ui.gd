extends WindowDialog

onready var leftHandle: Node = $DoorClosed/HandleLeft
onready var rightHandle: Node = $DoorClosed/HandleRight
onready var doorOpened: Node = $DoorOpened
onready var doorClosed: Node = $DoorClosed
onready var handle_maxy: int = leftHandle.position.y
onready var handle_miny: int = leftHandle.position.y - 50

var left_in: bool = false
var left_grab: bool = false
var right_in: bool = false
var right_grab: bool = false
var prev_mouse_coord: Vector2
var maxrot = PI/3

var taskResource: TaskResource

func _ready():
	pass


func _on_HandleLeft_mouse_entered():
	left_in = true

func _on_HandleRight_mouse_entered():
	right_in = true

func _on_HandleLeft_mouse_exited():
	left_in = false
	left_grab = false

func _on_HandleRight_mouse_exited():
	right_in = false
	right_grab = false

func doorChange(status, task_res):
	if status:
		doorOpen()
	else:
		doorClose()

func doorClose():
	doorClosed.visible = true
	doorOpened.visible = false

func doorOpen():
	doorClosed.visible = false
	doorOpened.visible = true

func doorHandleCheck():
	if rightHandle.rotation <= -maxrot * 0.9 and leftHandle.rotation >= maxrot * 0.9:
		doorOpen()

func handleMove(event, handle_node, left_side: bool):
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

func _on_HandleLeft_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		left_grab = true
		prev_mouse_coord = event.position
	elif left_grab:
		handleMove(event, leftHandle, true)

func _on_HandleRight_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		right_grab = true
		prev_mouse_coord = event.position
	elif right_grab:
		handleMove(event, rightHandle, false)

func _on_ChemicalCabinet_popup_hide():
	pass
