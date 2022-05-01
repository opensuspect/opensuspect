extends Node2D

func _ready():
	if not Connections.isServer():
		return
	for i in range(0, 2):
		for j in range(0, 2):
			Items.createItemServer("Powder Bottle", Vector2(i * 40, j * 70) + position)
