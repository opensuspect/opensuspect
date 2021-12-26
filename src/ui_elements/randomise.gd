extends Button

onready var Appearance = get_node("/root/Appearance")

func _ready():
	_randomizeConfig()

func _on_Player_pressed():
	_changeMenu()

func _randomizeConfig():
	Appearance.randomizeConfig()
	$menu_player/Skeleton.applyConfig()

func _changeMenu():
	print(get_parent().get_parent().get_parent().get_parent())
