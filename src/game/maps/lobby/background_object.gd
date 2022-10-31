extends IPoolable
class_name BackgroundObject

onready var sprite: Sprite = $Sprite

# Array of textures to choose from and set the sprite to
export (Array, Texture) var textures

func _ready() -> void:
	var random_index : int = 0
	if len(textures) > 0:
		random_index = randi() % len(textures)
		$Sprite.texture = textures[random_index]
	else:
		printerr("You should have at least one texture in the textures array")
