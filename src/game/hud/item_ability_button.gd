extends Control

@onready var dropButton: TextureButton = $Button

var item: ItemResource
var abilityName: String

func _ready():
	assert(item != null) #,"The item should be set right when this scene is instanced.")
	dropButton.texture_normal = item.abilityActivateIcon(abilityName)

func setupButton(newItem: ItemResource, newName: String) -> void:
	item = newItem
	abilityName = newName

func _on_Button_button_down():
	item.attemptActivate(abilityName)
