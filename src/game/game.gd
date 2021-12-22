extends Node2D

onready var mapNode: Node2D = $Map
onready var characterNode: Node2D = $Characters
onready var rng = RandomNumberGenerator.new()

var characterTemplate: Resource = ResourceLoader.load("res://game/character/character.tscn")

func loadMap(mapPath: String) -> void:
	var mapToLoad: Node = ResourceLoader.load(mapPath).instance()
	add_child_below_node(mapNode, mapToLoad)

func addCharacter(networkID) -> void:
	var newCharacterResource: CharacterResource = Characters.createCharacter(networkID)
	var newCharacter: KinematicBody2D = newCharacterResource.getCharacterNode()
	var position: Vector2
	position.x = rng.randi_range(100, 500)
	position.y = rng.randi_range(100, 500)
	add_child_below_node(characterNode, newCharacter)
	newCharacterResource.setPosition(position)
