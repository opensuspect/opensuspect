extends "res://game/ui_elements/task_ui_base.gd"

onready var mainValve: Area2D = $Control/MainValve
onready var reductorValve: Area2D = $Control/ReductorValve
onready var highPressNeedle: Sprite = $Control/HighPressureNeedle
onready var lowPressNeedle: Sprite = $Control/LowPressureNeedle

var mainValveIn: bool = false
var mainValveGrab: bool = false
var mainValveMaxRot: float = PI / 2
var mainValvePrevRot: float = 0
var redValveIn: bool = false
var redValveGrab: bool = false
var redValvePrevRot: float = 0
var redValveMaxTurn: int = 5
var prevMouseCoord: Vector2

func attachNewResource(newRes: TaskResource) -> void:
	var newState: Dictionary = _attachNewResource(newRes)
	setHighPressNeedle(newRes.getHighPressure())

func mainValveOpen():
	emitStateChange()

func emitStateChange():
	var newState: Dictionary = {}
	newState["main valve"] = mainValve.rotation_degrees
	newState["reductor valve"] = reductorValve.rotation_degrees
	emit_signal("stateChanged", newState)

func setHighPressNeedle(pressure: float) -> void:
	var minRot: float = 77
	var maxRot: float = 350
	var maxPressure: float = 6
	pressure = min(pressure, maxPressure)
	pressure = max(pressure, 0)
	highPressNeedle.rotation_degrees = (
		(pressure / maxPressure) * (maxRot - minRot) + minRot
	)

func setLowPressNeedle(pressure: float) -> void:
	var minRot: float = 15
	var maxRot: float = 285
	var maxPressure: float = 0.5
	pressure = min(pressure, maxPressure)
	pressure = max(pressure, 0)
	lowPressNeedle.rotation_degrees = (
		(pressure / maxPressure) * (maxRot - minRot) + minRot
	)

func setMainValve(rotation: float) -> void:
	mainValve.rotation_degrees = rotation

func setReductorValve(rotation: float) -> void:
	reductorValve.rotation_degrees = rotation

func _on_MainValve_mouse_entered() -> void:
	mainValveIn = true

func _on_MainValve_mouse_exited() -> void:
	mainValveIn = false
	mainValveGrab = false
	mainValvePrevRot = mainValve.rotation
	emitStateChange()

func _on_MainValve_input_event(viewport, event, shape_idx) -> void:
	if (event is InputEventMouseButton && event.pressed):
		mainValveGrab = true
		prevMouseCoord = event.position
	elif mainValveGrab:
		var posdiff: Vector2
		posdiff = event.position - mainValve.global_position
		mainValve.rotation = min(posdiff.angle() + PI / 2, mainValveMaxRot)
		mainValve.rotation = max(mainValve.rotation, 0)
		if abs(mainValve.rotation - mainValvePrevRot) > PI / 8:
			emitStateChange()
			mainValvePrevRot = mainValve.rotation
		if (
			mainValve.rotation_degrees < mainValveMaxRot / PI * 180 - 5 and
			mainValvePrevRot > mainValveMaxRot - 0.087
		):
			emitStateChange()
			mainValvePrevRot = mainValve.rotation
		if (
			mainValve.rotation_degrees > mainValveMaxRot / PI * 180 - 5 and
			mainValvePrevRot < mainValveMaxRot - 0.087
		):
			mainValveOpen()
			mainValvePrevRot = mainValve.rotation
		prevMouseCoord = event.position

func _on_ReductorValve_mouse_entered():
	redValveIn = true

func _on_ReductorValve_mouse_exited():
	redValveIn = false
	redValveGrab = false
	redValvePrevRot = reductorValve.rotation
	emitStateChange()

func _on_ReductorValve_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		redValveGrab = true
		prevMouseCoord = event.position
	elif redValveGrab:
		var prevMouseRelPos: Vector2 = prevMouseCoord - reductorValve.global_position
		var currMouseRelPos: Vector2 = event.position - reductorValve.global_position
		var angleChange: float = prevMouseRelPos.angle_to(currMouseRelPos)
		var currRot: float = reductorValve.rotation
		if currRot < 0:
			currRot += 2 * PI
		if currRot + angleChange < 0:
			reductorValve.rotation = 0
			redValvePrevRot = reductorValve.rotation
			emitStateChange()
		elif currRot + angleChange > 2 * PI * redValveMaxTurn:
			reductorValve.rotation = 2 * PI * redValveMaxTurn
			redValvePrevRot = reductorValve.rotation
			emitStateChange()
		else:
			reductorValve.rotation = currRot + angleChange
			if abs(reductorValve.rotation - redValvePrevRot) > PI / 8:
				emitStateChange()
				redValvePrevRot = reductorValve.rotation
		prevMouseCoord = event.position
