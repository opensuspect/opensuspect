extends Control

func _on_Back_pressed():
	get_parent().setVisibleMenuWithLogo(0)
	queue_free()
