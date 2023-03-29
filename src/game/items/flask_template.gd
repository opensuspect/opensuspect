extends ItemTemplate
class_name FlaskTemplate

@export var textureFull: Texture2D
@export var hudTextureFull: Texture2D = null
@export var pickUpTextureFull: Texture2D = null
@export var abilityTexture: Texture2D = null

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
		itemResource.set(property, super.get(property))
	itemResource._abilities = ["Pour"]
	itemResource._abilityIcons = {"Pour": abilityTexture}
