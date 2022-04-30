extends ItemTemplate
class_name FlaskTemplate

export var textureFull: Texture
export var hudTextureFull: Texture = null
export var pickUpTextureFull: Texture = null

func createItemResource(properties: Dictionary) -> ItemResource:
	# initialize a new ItemResource
	var itemResource: ItemResource = FlaskResource.new()
	if "full" in properties:
		itemResource.setFullness(properties["full"])
	return itemResource

func configureItemResource(itemResource: ItemResource):
	# transfer over general item info to itemResource
	var propertyList: Array = [
		"itemName", "texture", "textureScale", "hudTexture",
		"hudTextureScale", "pickUpTexture", "pickUpTextureScale",
		"pickUpRotation", "textureFull", "hudTextureFull",
		"pickUpTextureFull"]
	for property in propertyList:
		itemResource.set(property, get(property))
