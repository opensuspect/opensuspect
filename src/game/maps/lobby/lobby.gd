extends "res://game/maps/map_template.gd"

onready var lobbyCamera: Camera2D = $CustomCamera

func _ready() -> void:
	._ready()
	lobbyCamera.current = true
