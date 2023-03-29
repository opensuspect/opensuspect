extends Control

@onready var skin = $MarginContainer/VBoxContainer/SkinColor
@onready var fhair = $MarginContainer/VBoxContainer/FHairColor
@onready var hair = $MarginContainer/VBoxContainer/HairColor

signal setColor(shader, colorMap, position)

# --Private Functions--

func _draw():
	Appearance.connect("appearanceChanged",Callable(self,"_setCursorPos")) # Signal from appearance to set skeleton config
	_setCursorPos()

# Sets the cursor position for all color pickers
func _setCursorPos():
	var skinInfo = Appearance.currentColors["skin_color"]
	var fhairInfo = Appearance.currentColors["fhair_color"]
	var hairInfo = Appearance.currentColors["hair_color"]
	skin.showPreview(Vector2(skinInfo["XPos"], skinInfo["YPos"]))
	fhair.showPreview(Vector2(fhairInfo["XPos"], fhairInfo["YPos"]))
	hair.showPreview(Vector2(hairInfo["XPos"], hairInfo["YPos"]))

# --Signal Functions--

func _on_SkinColor_colorOnClick(colorMap, position):
	emit_signal("setColor", "skin_color", colorMap, position)

func _on_FHairColor_colorOnClick(colorMap, position):
	emit_signal("setColor", "fhair_color", colorMap, position)

func _on_HairColor_colorOnClick(colorMap, position):
	emit_signal("setColor", "hair_color", colorMap, position)
