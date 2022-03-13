extends Resource
class_name Ability

var _name: String = ""

func _init() -> void:
	_name = ""

func getName() -> String:
	return _name
