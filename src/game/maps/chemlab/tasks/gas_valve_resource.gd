extends TaskResource
class_name GasValveResource

func init(newNode: YSort) -> void:
	.init(newNode)
	taskState["main valve"] = 0
	taskState["reductor valve"] = 0
	taskState["base pressure"] = 2.0

func stateChanged(newState: Dictionary) -> void:
	.stateChanged(newState)
	taskUiNode.setHighPressNeedle(getHighPressure())
	taskUiNode.setLowPressNeedle(getLowPressure())

func stateRemoteChange(newState: Dictionary) -> bool:
# warning-ignore:return_value_discarded
	.stateRemoteChange(newState)
	if taskUiNode != null:
		taskUiNode.setHighPressNeedle(getHighPressure())
		taskUiNode.setLowPressNeedle(getLowPressure())
	return true

func getHighPressure() -> float:
	if taskState["main valve"] < 89:
		return 0.0
	return taskState["base pressure"]

func getLowPressure() -> float:
	if taskState["main valve"] < 89:
		return 0.0
	if taskState["reductor valve"] < 360:
		return 0.0
	var pressure: float
	pressure = (
		taskState["base pressure"] * 0.2 *
		(taskState["reductor valve"] - 360) / (360 * 4)
	)
	return pressure

func returnOutput(outputName: String):
	if not outputName in outputVariables:
		assert (false, "The required output can not be provided")
		return null
	return getLowPressure()
