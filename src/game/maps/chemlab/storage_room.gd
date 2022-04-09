extends Node2D

func _ready():
	for i in range(0, 10):
		for j in range(0, 4):
			var new_item: ItemResource
			new_item = Items.createItem("Powder Bottle")
			new_item.getItemNode().position = Vector2(i * 40, j * 70)
			add_child(new_item.getItemNode())
