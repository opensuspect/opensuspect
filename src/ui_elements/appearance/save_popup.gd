extends PopupPanel

onready var inputName = $MarginContainer/HBoxContainer/Center/VBox/Name

var configData: Dictionary

const NAMESPACE = "appearance"

# --Public Variables--

func saveConfig(configName):
	_setupData()
	_appendConfig(configName)
	_saveData()
	self.hide()

# --Private Variables--

func _setupData():
	if GameData.exists(NAMESPACE):
		configData = GameData.read(NAMESPACE)

func _appendConfig(configName):
	configName = Resources.formatString(configName)
	configData[configName] = {
		"Outfit": Appearance.currentOutfit,
		"Colors": Appearance.currentColors
	}

func _saveData():
	GameData.write(NAMESPACE, configData)

func _on_Save_pressed():
	saveConfig(inputName.text)
