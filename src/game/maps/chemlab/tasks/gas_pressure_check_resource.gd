extends TaskResource
class_name GasPressChResource

func stateRemoteChange(newState: Dictionary) -> bool:
# warning-ignore:return_value_discarded
	.stateRemoteChange(newState)
	if taskUiNode != null:
		var pressure: float
		for index in range(len(inputVariables)):
			pressure = getInput(inputVariables[index])
			taskUiNode.setNeedle(index, pressure)
	return true
