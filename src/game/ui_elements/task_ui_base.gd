extends ColorRect

signal stateChanged
signal action
signal deactivate

func attachNewResource(newRes: Resource) -> void:
	var newState: Dictionary = newRes.activateUi(self)

func _on_TaskUi_hide() -> void:
	emit_signal("deactivate")

func changedTaskState(newState: Dictionary) -> void:
	pass
