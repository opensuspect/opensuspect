extends Resource
class_name Ability

var _name: String = ""
var _abilityHudNode: Node
var _owner # THIS SHOULD BE CharacterResource (typcheck breaks: cyclic dependency)

func _init() -> void:
	_name = ""

func getName() -> String:
	return _name

func createAbilityHudNode() -> Node:
	var new_node: Node = Button.new()
	new_node.text = _name
	_abilityHudNode = new_node
	return new_node

func activate() -> void:
	pass

func canExecute(properties: Dictionary) -> bool:
	return false

func execute(properties: Dictionary) -> void:
	pass

# newOwner SHOULD BE CharacterResource (typcheck breaks: cyclic dependency)
func registerOwner(newOwner) -> void:
	_owner = newOwner

