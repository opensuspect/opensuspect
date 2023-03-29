extends Control

@onready var dropButton: TextureButton = $Button

var task: TaskResource

func _ready():
	assert(task != null) #,"The item should be set right when this scene is instanced.")
	dropButton.texture_normal = task.buttonSprite

func setupButton(newTask: TaskResource) -> void:
	task = newTask

func _on_Button_button_down():
	task.interact()
