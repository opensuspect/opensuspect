extends Node2D

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters

func load_map(mapPath: String) -> void:
	var mapToLoad: Node = ResourceLoader.load(mapPath).instance()
	add_child_below_node(mapNode, mapToLoad)
