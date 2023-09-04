extends Node

func addChild(parent, path):
	print_debug(path)
	parent.add_child(load(path).instance())
