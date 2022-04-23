extends Control

onready var itemIcon: Sprite = $ItemSprite
onready var dropButton: TextureButton = $Button

var item: ItemResource

func _ready():
	assert(item != null, "The item should be set right when this scene is instanced.")
	itemIcon.texture = item.getHudTexture()
	itemIcon.scale = item.getHudTextureScale()

func setItemResource(new_item: ItemResource) -> void:
	item = new_item

func _on_Button_button_down():
	item.attemptDrop()
