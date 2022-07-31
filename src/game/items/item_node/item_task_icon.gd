extends Node2D

onready var _sprite: Sprite = $ItemSprite

var _buttonTexture: Texture
var _textureScale: Vector2

func _ready() -> void:
	_sprite.texture = _buttonTexture
	_sprite.scale = _textureScale

func setTexture(buttonTexture: Texture, textureScale: Vector2) -> void:
	_buttonTexture = buttonTexture
	_textureScale = textureScale
