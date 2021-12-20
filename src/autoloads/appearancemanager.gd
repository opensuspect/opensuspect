extends Node

# --------------------------------------------------------------
# This autoload script is keeping persistent information about the customized
# appearance of players so when the actual player nodes (or other nodes
# representing the players) are instanced, the information is available at one
# place.
# --------------------------------------------------------------

# Location of the saved customization
const customization_path : String = "user://custom_appearance.save"
# Variables that manage the in-game appearance of the player character
var customization_dict: Dictionary
var my_customization: Dictionary
var customization_change: bool = true
# Variables that store the location of files used for appearance editing
var sprites_dir = "res://assets/player/textures/characters/customizable/"
var player_parts: Dictionary = {
	"Clothes": [
		"left_arm",
		"left_leg",
		"pants",
		"right_leg",
		"clothes",
		"right_arm",
	],
	"Body": ["body"],
	"Facial Hair": ["facial_hair"],
	"Face Wear": ["face_wear"],
	"Hat/Hair": ["hat_hair"],
	"Mouth": ["mouth"],
}
var part_sprite_list: Dictionary = {
	"Clothes": {
		"beige_suit": tr("Beige suit"),
		"blue_blaser_skirt": tr("Blue blaser and skirt"),
		"brown_suit": tr("Brown suit"),
		"labcoat": tr("Lab coat"),
		"pink_sweater-blue_jeans": tr("Pink sweater and blue jeans"),
		"police_uniform": tr("People's Police uniform"),
		"tuxedo": tr("Tuxedo"),
		"white_shirt-red_sweater": tr("White shirt with red sweater")
	},
	"Body": {
		"black_round_eyes-big_nose": tr("Black, round eyes and big nose"),
		"black_round_eyes-small_nose": tr("Black, round eyes and small nose"),
		"closed_eyes-big_nose": tr("Closed eyes and big nose"),
		"closed_eyes-small_nose": tr("Closed eyes and small nose")
	},
	"Facial Hair": {
		"eyebrows_1": tr("Eyebrows 1"), "eyebrows_2": tr("Eyebrows 2"),
		"moustache_1": tr("Moustache 1"),
		"sideburns_eyebrows_1": tr("Sideburns and eyebrows 1"),
		"sideburns_eyebrows_2": tr("Sideburns and eyebrows 2"),
		"sideburns_eyebrows_3": tr("Sideburns and eyebrows 3"),
		"sideburns_long": tr("Long sideburns")
	},
	"Face Wear": {
		"empty": tr("Nothing"), "glasses": tr("Glasses"),
		"monocle": tr("Monocle"), "sunglasses": tr("Sunglasses")
	},
	"Hat/Hair": {
		"bald": tr("Bald"), "hair_bob": tr("Hair, bob"),
		"hair_curly": tr("Hair, curly"), "hair_long": tr("Hair, long"),
		"hair_ponytail": tr("Hair, ponytail"), "hair_short": tr("Hair, short"),
		"hat_beige": tr("Hat, beige"), "hat_brown": tr("Hat, brown"),
		"hat_police": tr("People's Police hat")
	},
	"Mouth": {
		"angry": tr("Angry"), "concerned": tr("Concerned"), "content": tr("Content"),
		"small_smile": tr("Small smile"), "small_smile_2": tr("Small smile 2"),
		"smile": tr("Smile")
	},
}
var custom_color_files: Dictionary = {
	"Skin Color": "skin_color", "Hair Color": "hair_color", "Facial Hair Color": "facial_hair_color"
	}
# This will control the color maps for each customizable color
var custom_colors: Dictionary = {}
# The selected colors should be stored as X-Y coordinates on the color map 0-499
const COLOR_XY = 500

signal apply_appearance(id)

func _ready():
	# When this script is ready, it loads the saved customization of the user.
	
	print(part_sprite_list)
	var color_map: Image
	var texture: StreamTexture
	for color_map_name in custom_color_files.keys():
		texture = load(sprites_dir + custom_color_files[color_map_name] + ".png")
		color_map = texture.get_data()
		custom_colors[color_map_name] = color_map
	
	my_customization = SaveLoadHandler.load_data(customization_path)
	if my_customization.empty():
		my_customization = randomAppearance()
	my_customization = setColors(my_customization)

#	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

#-------------------------------------------------------------------------------
# Functions related to handling the low-level appearance modifications such as
# handling the sprite files, etc.
#-------------------------------------------------------------------------------

func getColorMap(color_map_name: String):
	# Returns the custom color map by the name
	if custom_color_files.has(color_map_name):
		return custom_colors[color_map_name]
	return null

func getFilePaths(part_name: String, selection_name: String):
	#-----------------
	# Returns all the file names that are related to a certain customization of a 
	# part: part_name is the high-level, uniquely customizable part, while selection_name
	# is the name of the selection for the certain part.
	#-----------------
	var paths = []
	var directory: String
	
	if not player_parts.has(part_name):
		return []
	for directory_num in len(player_parts[part_name]):
		directory = player_parts[part_name][directory_num]
		paths.append(sprites_dir + directory + "/" + selection_name + ".png")
	return paths

func getPlayerParts():
	return player_parts

func partFiles(part: String) -> Dictionary:
	# ---------------------------
	# Returns a directory of file names and display names that are available for
	# the part customization
	# ----------------
	return part_sprite_list[part]

func colorFromMapXY(color_map, x_rel, y_rel):
	# ----------------------------
	# Returns the color of the color map at x_rel, y_rel relative coordinates where
	# both x_rel and y_rel are in the range of [0..COLOR_XY]
	# ----------------------------
	var max_x: int
	var max_y: int
	var x: int
	var y: int
	var rgba: Color
	max_x = color_map.get_width()
	max_y = color_map.get_height()
	x = int(float(x_rel) / COLOR_XY * max_x)
	y = int(float(y_rel) / COLOR_XY * max_y)
	color_map.lock()
	rgba = color_map.get_pixel(x, y)
	color_map.unlock()
	return rgba

func setColors(customization):
	# ------------------------
	# Based on the coordinates on the color maps, it adds rgb values to the customization
	# dictionary received.
	# -----------------------
	var rgba: Color
	for color_map_name in custom_colors.keys():
		rgba = colorFromMapXY(custom_colors[color_map_name],
			customization[color_map_name]["x"],
			customization[color_map_name]["y"])
		customization[color_map_name]["r"] = rgba.r
		customization[color_map_name]["g"] = rgba.g
		customization[color_map_name]["b"] = rgba.b
	return customization

func randomAppearance():
	var available_values: Dictionary = {}
	var customization: Dictionary = {}
	var colors: Dictionary = {}
	for part in player_parts.keys():
		available_values = partFiles(part)
		customization[part] = Helpers.pick_random(available_values.keys())
	for color_map_name in custom_colors.keys():
		colors["x"] = randi() % COLOR_XY
		colors["y"] = randi() % COLOR_XY
		customization[color_map_name] = colors.duplicate()
	return customization
