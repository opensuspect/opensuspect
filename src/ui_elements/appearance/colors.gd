extends Control

signal setColor(color, shader)

# --Signal Functions--

func _on_SkinColor_colorOnClick(color):
	emit_signal("setColor", color, "skin_color")

func _on_FHairColor_colorOnClick(color):
	emit_signal("setColor", color, "fhair_color")

func _on_HairColor_colorOnClick(color):
	emit_signal("setColor", color, "hair_color")
