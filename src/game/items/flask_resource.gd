extends ItemResource
class_name FlaskResource

var textureFull: Texture
var hudTextureFull: Texture = null
var pickUpTextureFull: Texture = null

var isFull: bool = false

func setFullness(newState: bool) -> void:
	isFull = newState

func getTexture() -> Texture:
	if _holder == null:
		if isFull:
			return textureFull
		return texture
	if isFull:
		return pickUpTextureFull
	return pickUpTexture

func getHudTexture() -> Texture:
	if isFull:
		return hudTextureFull
	return hudTexture

func itemAbilities() -> Array:
	if isFull:
		return _abilities
	else:
		return []

# warning-ignore:unused_argument
func canBeActivated(abilityName: String, properties: Dictionary) -> bool:
	if not abilityName in _abilities:
		return false
	if abilityName == _abilities[0]:
		return isFull
	else:
		assert(false, "Unreachable")
	return false

func attemptActivate(abilityName: String) -> void:
	# properties variable a placeholder. Some item ability might have a target,
	# or an effect that is dependent on the interaction with the environment, in
	# that case, this fucntion should gather that information in the properties
	# dictionary.
	var properties: Dictionary = {}
	if not canBeActivated(abilityName, properties):
		return
	TransitionHandler.gameScene.itemActivateAttempt(itemId, abilityName, properties)

# warning-ignore:unused_argument
func activate(abilityName: String, properties: Dictionary) -> void:
	if not abilityName in _abilities:
		return
	if abilityName == _abilities[0]:
		isFull = false
		_itemNode.setSprite()
	else:
		assert(false, "Unreachable")
