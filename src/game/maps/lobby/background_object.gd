extends IPoolable
class_name BackgroundObject

@onready var sprite: Sprite2D = $Sprite2D

# Array of textures to choose from and set the sprite to
@export (Array, Texture2D) var textures

func _ready() -> void:
	var random_index : int = 0
	if len(textures) > 0:
		random_index = randi() % len(textures)
		$Sprite2D.texture = textures[random_index]
	else:
		printerr("You should have at least one texture in the textures array")
