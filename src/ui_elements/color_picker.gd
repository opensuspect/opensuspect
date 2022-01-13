extends Control

onready var colorImage: Sprite = $ColorImage

export var colorMapPath: String = "res://game/character/assets/colormaps/skin_color.png"

signal colorOnClick(color) # Send the color of the clicked position

var imageScale: Vector2 # Scale of the image
var windowDimensions: Vector2

var selectedColor: Color
var selectedColorPosition: Vector2

# --Private Functions--
func _on_ColorPicker_gui_input(event):
	if Input.is_action_pressed("ui_press") and _checkValidPos(event.position):
		selectedColorPosition = event.position
		selectedColor = Appearance.colorFromMapPos(colorMapPath, selectedColorPosition, imageScale)
		emit_signal("colorOnClick", selectedColor)
		colorImage.selectedColor = selectedColor
		colorImage.selectedColorPosition = selectedColorPosition
		colorImage.update()

func _draw():
	windowDimensions = self.get_size()
	var colorMapImage = load(colorMapPath)
	set_default_cursor_shape(3) # Set to cross cursor
	colorImage.texture = colorMapImage
	imageScale = _getImageScale(colorMapImage) # Set the image scale
	_resizeColorImage() # Resize the image

func _getImageScale(colorMapImage) -> Vector2:
	var scale: Vector2
	var mapWidth: int = colorMapImage.get_width()
	var mapHeight: int = colorMapImage.get_height()
	var windowWidth = windowDimensions.x
	var windowHeight = windowDimensions.y
	scale.x = windowWidth / mapWidth
	scale.y = windowHeight / mapHeight
	return(scale)

func _resizeColorImage() -> void:
	colorImage.scale.x = imageScale.x
	colorImage.scale.y = imageScale.y

func _checkValidPos(position) -> bool:
	if position.x > windowDimensions.x || position.y > windowDimensions.y:
		return(false)
	elif position.x < 0 || position.y < 0:
		return(false)
	else:
		return(true)
