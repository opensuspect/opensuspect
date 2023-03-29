extends ColorRect

signal stateChanged
signal action
signal deactivate

func attachNewResource(newRes: TaskResource) -> void:
	var newState: Dictionary = _attachNewResource(newRes)

func _attachNewResource(newRes: TaskResource) -> Dictionary:
	return newRes.activateUi(self)

func _on_TaskUi_hide() -> void:
	emit_signal("deactivate")

func changedTaskState(newState: Dictionary) -> void:
	pass

func changedItemButtons(itemButtons: Array) -> void:
	var canPickOut: bool
	var itemId: int
	for itemButton in itemButtons:
		itemId = itemButton.getItemId()
		canPickOut = (
			Characters.getMyCharacterResource().canPickUpItem(Items.getItemResource(itemId))
		)
		itemButton.setButtonVisibility(canPickOut)

func resetItems(taskRes: TaskResource, itemPlace: Node2D) -> Dictionary:
	for item in itemPlace.get_children():
		item.queue_free()
	var itemsInTask: Dictionary = taskRes.getItemResources()
	var itemButtons: Dictionary
	for itemLoc in itemsInTask:
		var itemRes = itemsInTask[itemLoc]
		var itemButton: Node2D = itemRes.createTaskButton()
		itemButton.setItemId(itemRes.getId())
		itemButton.connect("attemptPickUp",Callable(taskRes,"attemptItemPickOut"))
		itemButtons[itemLoc] = itemButton
		itemPlace.add_child(itemButton)
	return itemButtons


func _on_CloseButton_pressed():
	Scenes.back()
