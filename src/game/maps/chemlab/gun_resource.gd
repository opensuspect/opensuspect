extends Ability
class_name GunAbility

var gunRangeScene: PackedScene = preload("res://game/maps/chemlab/gun.tscn")
var gunUiScene: PackedScene = preload("res://game/maps/chemlab/ui_elements/gun_hud.tscn")
var gunRangeNode: Area2D = null

var chamberCapacity: int = 1
var chamberAmmo: int = 1
var reloadTime: int = 10

var killableCharacters: Array = []

signal action

func _init() -> void:
	_name = "Gun"

func registerOwner(newOwner) -> void:
	.registerOwner(newOwner)
	gunRangeNode = gunRangeScene.instance()
	newOwner.getCharacterNode().attachAbility(gunRangeNode)
	gunRangeNode.connect("bodyEntered", self, "characterEnteredZone")
	gunRangeNode.connect("bodyExited", self, "characterExitedZone")
	connect("action", TransitionHandler.gameScene, "abilityActivate")

func createAbilityHudNode() -> Node:
	_abilityHudNode = gunUiScene.instance()
	_abilityHudNode.connect("killButtonPressed", self, "activate")
	_abilityHudNode.connect("reoladButtonPressed", self, "secondaryActivate")
	_abilityHudNode.activateKillButton(len(killableCharacters) > 0)
	return _abilityHudNode

func characterEnteredZone(characterRes: CharacterResource) -> void:
	if not characterRes == _owner and not characterRes in killableCharacters:
		killableCharacters.append(characterRes)
		if _abilityHudNode != null:
			_abilityHudNode.activateKillButton(true)

func characterExitedZone(characterRes: CharacterResource) -> void:
	if characterRes in killableCharacters:
		var characterIndex: int = killableCharacters.find(characterRes)
		killableCharacters.pop_at(characterIndex)
	if len(killableCharacters) == 0:
		if _abilityHudNode != null:
			_abilityHudNode.activateKillButton(false)

func activate() -> void:
	if chamberAmmo < 1:
		return
	
	var myPosition: Vector2 = _owner.getGlobalPosition()
	var otherPosition: Vector2
	var distance: float
	var mindist: float = INF
	var clostestId: int = -1

	for character in gunRangeNode.get_overlapping_bodies():
		var id: int = character.getNetworkId()
		if id == Connections.getMyId():
			continue
		if not character.getCharacterResource().canBeKilled():
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
		if chamberAmmo < 1 and _owner.mainCharacter:
			_abilityHudNode.showReloadButton()
		if Connections.isServer():
			TransitionHandler.gameScene.killCharacterServer(properties["target"])
	if action == "reload":
		chamberAmmo = chamberCapacity
		if _owner.mainCharacter:
			_abilityHudNode.showKillButton()
		var killableCharCopy = killableCharacters.duplicate()
		for characterRes in killableCharCopy:
			if not characterRes.isAlive():
				var characterIndex: int = killableCharacters.find(characterRes)
				killableCharacters.pop_at(characterIndex)
		if len(killableCharacters) == 0:
			if _owner.mainCharacter and _abilityHudNode != null:
				_abilityHudNode.activateKillButton(false)

func canExecute(properties: Dictionary) -> bool:
	if properties["action"] == "kill":
		if chamberAmmo < 1:
			return false
		for character in killableCharacters:
			if character.getNetworkId() == properties["target"]:
				return true
	elif properties["action"] == "reload":
		if chamberAmmo < 1:
			return true
	return false
