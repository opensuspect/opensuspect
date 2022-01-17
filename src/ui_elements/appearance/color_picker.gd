extends Control

export var colorMapPath: String = "res://game/character/assets/colormaps/skin_color.png"

signal colorOnClick(colorMap, position) # Send the color of the clicked position

var windowDimensions: Vector2
var imageScale: Vector2 # Scale of the image
var colorMapImage: StreamTexture

var selectedColor: Color
var selectedColorPosition: Vector2

# --Public Functions--

# Takes a position, scales it and displays the preview box
func showPreview(pos: Vector2) -> void:
	call_deferred("_showPreview", pos) # Call deferred runs it when it is ready

# --Private Functions--

func _ready() -> void:
	colorMapImage = load(colorMapPath) # Load the image
	set_default_cursor_shape(3) # Set to cross cursor
	$ColorImage.texture = colorMapImage # Set the texture of the color map

# Setup on draw
func _draw() -> void:
	windowDimensions = self.get_size() # Set dimensions of the window
	imageScale = _getImageScale(colorMapImage) # Set the image scale
	_resizeColorImage() # Resize the image

# Set the preview, after correctly scaling it
func _showPreview(pos: Vector2) -> void:
	var color = Appearance.getColorFromPos(colorMapPath, pos)
	var scaledPos = pos * imageScale
	_setPreview(scaledPos, color)

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

func _setPreview(pos: Vector2, color: Color) -> void:
	var offset = ($Preview.rect_size / 2)
	$Preview.rect_position = pos - offset
	$Preview.color = color

# --Signal Functions--

## Recieve input from Color Picker gui events
func _on_ColorPicker_gui_input(event) -> void:
	## If player is pressing, and at a valid position, select the color
	if Input.is_action_pressed("ui_press") and _checkValidPos(event.position):
		# Downscale position back to normal
		var position: Vector2 = event.position / imageScale
		emit_signal("colorOnClick", colorMapPath, position)
