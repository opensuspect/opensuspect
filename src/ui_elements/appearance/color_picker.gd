extends Control

export var colorMapPath: String = "res://game/character/assets/colormaps/skin_color.png"

signal colorOnClick(color) # Send the color of the clicked position

var imageScale: Vector2 # Scale of the image
var windowDimensions: Vector2
var pressing: bool

# --Private Functions--

# Setup on draw
func _draw():
	windowDimensions = self.get_size() # Set dimensions of the window
	var colorMapImage = load(colorMapPath) # Load the image
	set_default_cursor_shape(3) # Set to cross cursor
	$ColorImage.texture = colorMapImage # Set the texture of the color map
	imageScale = _getImageScale(colorMapImage) # Set the image scale
	_resizeColorImage() # Resize the image

## Calculate the correct scale for the color map, based on parent controls
func _getImageScale(colorMapImage) -> Vector2:
	var scale: Vector2
	var mapWidth: int = colorMapImage.get_width()
	var mapHeight: int = colorMapImage.get_height()
	var windowWidth = windowDimensions.x
	var windowHeight = windowDimensions.y
	scale.x = windowWidth / mapWidth
	scale.y = windowHeight / mapHeight
	return(scale)

## Scale the color image
func _resizeColorImage() -> void:
	$ColorImage.scale.x = imageScale.x
	$ColorImage.scale.y = imageScale.y

## Check if click is in a valid position (not outside color selector)
func _checkValidPos(position) -> bool:
	if position.x > windowDimensions.x || position.y > windowDimensions.y:
		return(false)
	elif position.x < 0 || position.y < 0:
		return(false)
	else:
		return(true)

func _showPreview(pos: Vector2, color: Color):
	$Preview.show()
	$Preview.rect_position = pos
	$Preview.color = color

# --Signal Functions--

## Recieve input from Color Picker gui events
func _on_ColorPicker_gui_input(event):
	## If player is pressing, and at a valid position, select the color
	if Input.is_action_pressed("ui_press") and _checkValidPos(event.position):
		var selectedColor = Appearance.colorFromMapPos(colorMapPath, event.position, imageScale)
		_showPreview(event.position, selectedColor)
		emit_signal("colorOnClick", selectedColor)
