extends PopupPanel

@onready var inputName = $MarginContainer/HBoxContainer/Center/VBox/Name

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
	if GameData.exists(NAMESPACE): # Check if data exists
		configData = GameData.read(NAMESPACE) # Read game data to config data dictionary

# Append the current config to the loaded data
func _appendConfig(configName):
	configName = Resources.formatString(configName)
	configData[configName] = {
		"Outfit": Appearance.currentOutfit,
		"Colors": Appearance.currentColors
	}

# Write the loaded data to disk
func _saveData():
	GameData.write(NAMESPACE, configData)

func _on_Save_pressed():
	if not inputName.text.is_empty():
		saveConfig(inputName.text)

func _on_Name_text_entered(new_text):
	if not new_text.is_empty():
		saveConfig(new_text)
