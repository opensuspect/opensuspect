extends Control

# --Private Variables--

func _ready():
	Appearance.applyConfig()
	
func _on_Back_pressed():
	get_tree().change_scene("res://ui_elements/appearance/appearance_editor.tscn")
