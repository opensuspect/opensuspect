extends Node2D

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
# Called when the node enters the scene tree for the first time.
func _ready():
	 load_map()

func load_map() -> void:
	var mapToLoad: Node = TransitionHandler.mapToLoad
	add_child_below_node(mapNode, mapToLoad)
