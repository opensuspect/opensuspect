extends Node

var baseScene: Node
var baseScenePath: String

var lowestScenePath: String

var loadedScenes: Dictionary
var sceneOrder: Array

# Overlay: Adds scene below as child of base scene, then switches visibility
# Rebase: Unloads all scenes, and sets the parent scene

# --Public Functions--

# Add a child scene to the base scene, and show it
func overlay(path: String) -> void:
	_hideAllLoaded()
	_checkLowestPath()
	if loadedScenes.has(path):
		_showLoaded(path)
	else:
		call_deferred("_deferredOverlay", path, true)
	if path != sceneOrder.back():
		sceneOrder.append(path)

# Preload a child scene to the base scene, but don't show it
func preloadOverlay(path: String) -> void:
	if not loadedScenes.has(path):
		call_deferred("_deferredOverlay", path, false)

# Set a new scene to be the base scene
func switchBase(path: String, baseLowest: bool) -> void:
	loadedScenes.clear()
	sceneOrder.clear()
	if baseLowest:
		lowestScenePath = path
	call_deferred("_deferredSwitchBase", path)

func setBase(scene):
	baseScene = scene
	baseScenePath = scene.filename

func setLowest(path: String):
	lowestScenePath = path
	overlay(path)

# Switch back to the previous scene
func back() -> void:
	var index = sceneOrder.size() - 1
	if index > 0:
		sceneOrder.remove(index)
		overlay(sceneOrder.back())
	else:
		if baseScene.has_method("_onBack"):
			baseScene.call("_onBack")

# --Private Functions--

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()

func _checkLowestPath() -> void:
	assert(not lowestScenePath.empty(), "Please set the lowest scene path")
	if sceneOrder.front() != lowestScenePath:
		sceneOrder.push_front(lowestScenePath)

func _deferredOverlay(path: String, focus: bool) -> void:
	var newScene = load(path).instance()
	baseScene.add_child(newScene)
	loadedScenes[path] = newScene
	if focus:
		_showLoaded(path)
	else:
		newScene.hide()

func _deferredSwitchBase(path: String) -> void:
	baseScenePath = path
	_reloadBase()
	loadedScenes[baseScenePath] = baseScene
	get_tree().set_current_scene(baseScene)

func _reloadBase() -> void:
	if baseScene != null:
		baseScene.free()
	baseScene = load(baseScenePath).instance()
	get_tree().get_root().add_child(baseScene)

# Hide all loaded child scenes
func _hideAllLoaded() -> void:
	for scene in loadedScenes.values():
		if scene != baseScene:
			scene.hide()

# Calls the _focus method if the scene has it
func _callFocusOnScene(scene: Node) -> void:
	if scene.has_method("_focus"):
		scene.call("_focus")

# Show the loaded scene matching the path
func _showLoaded(path: String) -> void:
	var scene = loadedScenes[path]
	scene.show()
	_callFocusOnScene(scene)
