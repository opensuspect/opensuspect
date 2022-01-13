extends Sprite

# TODO: make selectedColor and selectedColorPosition start out at the right place
# 	instead of null
var selectedColor: Color
var selectedColorPosition: Vector2

# --Private Functions--
func _draw():
	if selectedColor != null and selectedColorPosition != null:
		_drawColorPointer()

# draw a circle on top of the color gradient to show what color is currently selected
func _drawColorPointer():
	var outlineCircleRadius: float = 16.0
	var colorCircleRadius: float = 12.0
	var currentScale: Vector2 = scale
	# counteract the scaling done to this node so the circle doesn't turn out stretchy
	draw_set_transform(Vector2(0, 0), 0, Vector2(1 / scale.x, 1 / scale.y))
	# draw the black circle
	draw_circle(selectedColorPosition, outlineCircleRadius, Color("FDFE72")) # Standard yellow highlight color
	# draw the colored circle over the black circle
	draw_circle(selectedColorPosition, colorCircleRadius, selectedColor)
	# set the scale back to what it was before (probably Vector2(1, 1))
	draw_set_transform(Vector2(0, 0), 0, currentScale)
