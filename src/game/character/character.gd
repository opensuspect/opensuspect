extends "res://game/entity.gd"

# --Public Variables--
@onready var abilityPoint = $CharacterElements/Abilities
@onready var itemIntArea = $CharacterElements/ItemInteraction
@onready var taskIntArea = $CharacterElements/TaskInteraction
@onready var obstacleFinder = $ObstacleFinder

# --Signals--
signal player_disconnected(id)
signal itemInteraction(item, interaction)
signal taskInteraction(taskArea, interaction)

# function called when character is spawned
func spawn() -> void:
	pass

# PLACEHOLDER function for killing characters
func kill():
	# assert false because killing isn't implemented yet
	assert(false) #,"Not implemented yet")

func disconnected():
	## runs when this player disconnects from the server
	emit_signal("player_disconnected", networkId)
	# TODO: drop items, etc.

func setNameColor(newColor: Color) -> void:
	nameLabel.add_theme_color_override("font_color", newColor)

func die() -> void:
	rotation_degrees = 90

# get the role of this character
# string return type is PLACEHOLDER
func getRole() -> String:
	return _characterResource.getRole()

# get tasks assigned to this character node
func getTasks() -> Dictionary:
	return _characterResource.getTasks()
	
# get the outfit of the character
func getOutfit() -> Dictionary:
	return _characterResource.getOutfit()

func attachAbility(newAbility: Node2D) -> void:
	abilityPoint.add_child(newAbility)

func clearAbilities() -> void:
	if abilityPoint == null:
		return
	for ability in abilityPoint.get_children():
		ability.queue_free()

# get the position of the character
func getPosition() -> Vector2:
	## Return position
	return position

# get the global position of the character
func getGlobalPosition() -> Vector2:
	## Return global position
	return global_position

# set the global position of the character
func setGlobalPosition(newPos: Vector2) -> void:
	## update look direction based on movement
	setLookDirection(_getLookDirFromVec(newPos - global_position))
	global_position = newPos

# get the direction the character is looking
func getLookDirection() -> int:
	return lookDirection

func _on_ItemPickup_body_entered(body):
	if mainCharacter:
		# This pickup area should ONLY interact with items.
		var itemRes: ItemResource = body.getItemResource()
		emit_signal("itemInteraction", itemRes, "entered")

func _on_ItemPickup_body_exited(body):
	if mainCharacter:
		# This pickup area should ONLY interact with items.
		var itemRes: ItemResource = body.getItemResource()
		emit_signal("itemInteraction", itemRes, "exited")

func _on_TaskInteraction_area_entered(area):
	if mainCharacter:
		emit_signal("taskInteraction", area, "entered")

func _on_TaskInteraction_area_exited(area):
	if mainCharacter:
		emit_signal("taskInteraction", area, "exited")
