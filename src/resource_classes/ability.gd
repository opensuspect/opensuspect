extends Resource
class_name Ability

var _name: String = ""
var _abilityHudNode: Node
var _owner # THIS SHOULD BE CharacterResource (typcheck breaks: cyclic dependency)

func _init() -> void:
	_name = ""

func getName() -> String:
	return _name

func setAbilityHudNode(new_node: Node):
	_abilityHudNode = new_node

func abilityActivate() -> void:
	pass

func canActivate(properties: Dictionary) -> bool:
	return false

# newOwner SHOULD BE CharacterResource (typcheck breaks: cyclic dependency)
func registerOwner(newOwner) -> void:
	_owner = newOwner

