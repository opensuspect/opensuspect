extends Control

onready var itemIcon: Sprite = $ItemSprite
onready var pickUpButton: TextureButton = $Button

var item: ItemResource

func setItemResource(new_item: ItemResource) -> void:
	item = new_item
	call_deferred("setTexture")

func setTexture() -> void:
	itemIcon.texture = item.getHudTexture()
	itemIcon.scale = item.getHudTextureScale()



func _on_Button_button_down():
	pass
