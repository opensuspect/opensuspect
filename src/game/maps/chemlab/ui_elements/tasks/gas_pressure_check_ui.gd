extends "res://game/ui_elements/task_ui_base.gd"

@onready var pressureMeterNode: Control = $Control/PressureMeters
var pressureLabels: Array = []
var pressureNeedles: Array = []

func _ready():
	for meter in pressureMeterNode.get_children():
		pressureNeedles.append(meter.get_node("Needle"))
		pressureLabels.append(meter.get_node("Label"))

func attachNewResource(newRes: TaskResource) -> void:
	var newState: Dictionary = _attachNewResource(newRes)
	var pressure: float
	for index in range(len(newRes.inputVariables)):
		pressureLabels[index].text = newRes.inputVariables[index]
		pressure = newRes.getInput(newRes.inputVariables[index])
		setNeedle(index, pressure)

func setNeedle(index: int, pressure: float) -> void:
	var minRot: float = 46
	var maxRot: float = 316
	var maxPressure: float = 0.5
	pressure = min(pressure, maxPressure)
	pressure = max(pressure, 0)
	pressureNeedles[index].rotation_degrees = (
		(pressure / maxPressure) * (maxRot - minRot) + minRot
	)
