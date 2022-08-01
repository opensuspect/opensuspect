extends ColorRect

signal stateChanged
signal action
signal deactivate

func attachNewResource(newRes: TaskResource) -> void:
	var newState: Dictionary = newRes.activateUi(self)

func _on_TaskUi_hide() -> void:
	emit_signal("deactivate")

func changedTaskState(newState: Dictionary) -> void:
	pass

func resetItems(taskRes: TaskResource, itemPlace: Node2D) -> Dictionary:
	for item in itemPlace.get_children():
		item.queue_free()
	var itemsInTask: Dictionary = taskRes.getItemResources()
	var itemButtons: Dictionary
	for itemLoc in itemsInTask:
		var itemRes = itemsInTask[itemLoc]
		var itemButton: Node2D = itemRes.createTaskButton()
		itemButton.setItemId(itemRes.getId())
		itemButton.connect("attemptPickUp", taskRes, "attemptItemPickOut")
		itemButtons[itemLoc] = itemButton
		itemPlace.add_child(itemButton)
	return itemButtons
