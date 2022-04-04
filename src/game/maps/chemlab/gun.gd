extends Ability
class_name GunAbility

var gunRangeScene: PackedScene = preload("res://game/maps/chemlab/gun.tscn")
var gunUiScene: PackedScene = preload("res://game/maps/chemlab/ui_elements/gun_hud.tscn")
var gunRangeNode: Area2D = null
var killButton: TextureButton = null
var reloadButton: TextureButton = null

var chamberCapacity: int = 1
var chamberAmmo: int = 1
var reloadTime: int = 10

signal action

func _init() -> void:
	_name = "Gun"

func registerOwner(newOwner) -> void:
	.registerOwner(newOwner)
	gunRangeNode = gunRangeScene.instance()
	newOwner.getCharacterNode().attachAbility(gunRangeNode)
	connect("action", TransitionHandler.gameScene, "abilityActivate")

func createAbilityHudNode() -> Node:
	_abilityHudNode = gunUiScene.instance()
	killButton = _abilityHudNode.get_child(0)
	reloadButton = _abilityHudNode.get_child(1)
	killButton.connect("button_down", self, "activate")
	reloadButton.connect("button_down", self, "secondaryActivate")
	return _abilityHudNode

func activate() -> void:
	if chamberAmmo < 1:
		return
	
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
		var properties: Dictionary = {	"target": clostestId,
										"action": "kill",
										"ability": _name}
		emit_signal("action", properties)

func secondaryActivate() -> void:
	if chamberAmmo < 1:
		var properties: Dictionary = {	"action": "reload",
										"ability": _name}
		emit_signal("action", properties)

func execute(properties: Dictionary) -> void:
	var action: String = properties["action"]
	if action == "kill":
		chamberAmmo -= 1
		if not killButton == null and chamberAmmo < 1:
			killButton.hide()
			reloadButton.show()
		if Connections.isServer():
			TransitionHandler.gameScene.killCharacterServer(properties["target"])
	if action == "reload":
		chamberAmmo = chamberCapacity
		if killButton != null:
			reloadButton.hide()
			killButton.show()

func canExecute(properties: Dictionary) -> bool:
	if properties["action"] == "kill":
		if chamberAmmo < 1:
			return false
		for character in gunRangeNode.get_overlapping_bodies():
			if character.getNetworkId() == properties["target"]:
				return true
	elif properties["action"] == "reload":
		if chamberAmmo < 1:
			return true
	return false
