extends Node

var baseScene
var baseScenePath: String

var loadedScenes: Dictionary
var sceneOrder: Array

# Overlay: Adds scene below as child of base scene, then switches visibility
# Rebase: Unloads all scenes, and sets the parent scene

# --Public Functions--

# Add a child scene to the base scene, and show it
func overlay(path: String) -> void:
	_hideAllLoaded()
	if loadedScenes.has(path):
		_showLoaded(path)
	else:
		call_deferred("_deferredOverlay", path)
	if path != sceneOrder.back():
		sceneOrder.append(path)

# Set a new scene to be the base scene
func rebase(path: String) -> void:
	call_deferred("_deferredRebase", path)

# Switch back to the previous scene
func back() -> void:
	var index = sceneOrder.size() - 1
	sceneOrder.remove(index)
	if sceneOrder.empty():
		assert(false, "No scene to switch back to")
	else:
		overlay(sceneOrder.back())

# --Private Functions--

func _deferredOverlay(path: String):
	var newScene = load(path).instance()
	baseScene.add_child(newScene)
	newScene.call_deferred("_focus")
	loadedScenes[path] = newScene

func _deferredRebase(path: String):
	baseScenePath = path
	loadedScenes.clear()
	sceneOrder.clear()
	sceneOrder.append(baseScenePath)
	_reloadBase()
	get_tree().set_current_scene(baseScene)

func _reloadBase() -> void:
	if baseScene != null:
		baseScene.free()
	baseScene = load(baseScenePath).instance()
	get_tree().get_root().add_child(baseScene)

# Hide all loaded scenes
func _hideAllLoaded():
	for scene in loadedScenes.values():
		scene.hide()

# Show the loaded scene matching the path
func _showLoaded(path: String):
	var scene = loadedScenes[path]
	scene.show()
	scene.call_deferred("_focus")
