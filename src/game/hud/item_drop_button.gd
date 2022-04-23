extends Control

onready var itemIcon: Sprite = $ItemSprite
onready var dropButton: TextureButton = $Button

var item: ItemResource

signal buttonPressed

func setItemResource(new_item: ItemResource) -> void:
	item = new_item
	call_deferred("setTexture")

func setTexture() -> void:
	itemIcon.texture = item.getHudTexture()
	itemIcon.scale = item.getHudTextureScale()

func _on_Button_button_down():
	item.attemptPickUp()
