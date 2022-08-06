extends TaskResource
class_name GasValveResource

func init(newNode: YSort) -> void:
	.init(newNode)
	taskState["main valve"] = 0
	taskState["reductor valve"] = 0
	taskState["base pressure"] = 2.0
	taskState["output pressure"] = 0

func stateChanged(newState: Dictionary) -> void:
	.stateChanged(newState)
	taskUiNode.setHighPressNeedle(getHighPressure())
	taskUiNode.setLowPressNeedle(getLowPressure())

func stateRemoteChange(newState: Dictionary) -> bool:
	.stateRemoteChange(newState)
	taskUiNode.setHighPressNeedle(getHighPressure())
	taskUiNode.setLowPressNeedle(getLowPressure())
	taskUiNode.setMainValve(taskState["main valve"])
	taskUiNode.setReductorValve(taskState["reductor valve"])
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
