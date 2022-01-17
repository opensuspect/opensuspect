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
	_checkBasePath()
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
	if index > 1:
		sceneOrder.remove(index)
		overlay(sceneOrder.back())
	else:
		if baseScene.has_method("_onBack"):
			baseScene.call("_onBack")

# --Private Functions--

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back()

func _checkBasePath():
	if sceneOrder.front() != baseScenePath:
		sceneOrder.push_front(baseScenePath)

func _deferredOverlay(path: String):
	var newScene = load(path).instance()
	baseScene.add_child(newScene)
	_callFocusOnScene(newScene)
	loadedScenes[path] = newScene

func _deferredRebase(path: String):
	baseScenePath = path
	_checkBasePath()
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

func _callFocusOnScene(scene):
	if scene.has_method("_focus"):
		scene.call("_focus")

# Show the loaded scene matching the path
func _showLoaded(path: String):
	var scene = loadedScenes[path]
	scene.show()
	_callFocusOnScene(scene)
