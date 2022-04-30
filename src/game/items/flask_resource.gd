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
