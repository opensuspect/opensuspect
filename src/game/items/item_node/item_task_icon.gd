extends Node2D

onready var _sprite: Sprite = $ItemSprite
onready var _button: TextureButton = $InteractButton

var _buttonTexture: Texture
var _textureScale: Vector2
var _visibility: bool = true
var _itemId: int = -1

signal attemptPickUp

func _ready() -> void:
	_sprite.texture = _buttonTexture
	_sprite.scale = _textureScale
	var width: float = _buttonTexture.get_width() * _textureScale.x
	var height: float = _buttonTexture.get_height() * _textureScale.y
	var buttonWidth: float = _button.rect_size.x
	var buttonHeight: float = _button.rect_size.y
	_button.visible = _visibility
	_button.rect_position.x = width / 2 - buttonWidth
	_button.rect_position.y = height / 2 - buttonHeight

func setItemId(newId: int) -> void:
	if _itemId != -1:
		assert(false, "Should not change the ID on the fly")
	_itemId = newId

func getItemId() -> int:
	return _itemId

func setTexture(buttonTexture: Texture, textureScale: Vector2) -> void:
	_buttonTexture = buttonTexture
	_textureScale = textureScale

func setButtonVisibility(visible: bool) -> void:
	_visibility = visible
	if _button != null:
		_button.visible = _visibility

func _on_InteractButton_pressed():
	emit_signal("attemptPickUp", _itemId)
