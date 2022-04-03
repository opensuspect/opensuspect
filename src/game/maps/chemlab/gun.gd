extends Ability
class_name GunAbility

var gunRangeScene: PackedScene = preload("res://game/maps/chemlab/gun.tscn")
var gunRangeNode: Area2D = null

signal kill

func _init() -> void:
	_name = "Gun"

func registerOwner(newOwner):
	.registerOwner(newOwner)
	gunRangeNode = gunRangeScene.instance()
	newOwner.getCharacterNode().add_child(gunRangeNode)
	print_debug("Gun has been registered to ", newOwner)
	connect("kill", TransitionHandler.gameScene, "abilityActivate")

func abilityActivate():
	# Finds the character closest to my position
	# Kills the character immediately
	var myPosition: Vector2 = _owner.getGlobalPosition()
	var otherPosition: Vector2
	var distance: float
	var characterDict: Dictionary = Characters.getCharacterResources()
	var mindist: float = INF
	var clostestId: int = -1

	for character in gunRangeNode.get_overlapping_bodies():
		var id: int = character.getNetworkId()
		if id == Connections.getMyId():
			continue
		otherPosition = character.getGlobalPosition()
		distance = myPosition.distance_squared_to(otherPosition)
		if distance < mindist:
			mindist = distance
			clostestId = id

	if clostestId != -1:
		kill({"killed": clostestId})

func kill(properties: Dictionary):
	properties["ability"] = _name
	emit_signal("kill", properties)

func canActivate(properties: Dictionary) -> bool:
	print_debug(properties)
	return false
