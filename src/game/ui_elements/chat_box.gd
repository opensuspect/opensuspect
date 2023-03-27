extends MarginContainer

@export var removeLineBreaks: bool = true

@onready var chatHistory: RichTextLabel = $ChatContainer/ChatHistory
@onready var lineEdit: LineEdit = $ChatContainer/InputContainer/LineEdit

# chars considered empty (spaces, tabs, etc.)
var emptyChars: Array = [" ", "	", "\n", "\r", "\r\n"]
# chars that translate to line breaks
var breakChars: Array = ["\n", "\r", "\r\n"]

func _ready() -> void:
	TransitionHandler.gameScene.connect("chatMessageReceived", Callable(self, "displayMessage"))

func clearMessages() -> void:
	chatHistory.text = "Start chatting"

# ---------- RECEIVING MESSAGES -----------

func displayMessage(text: String, from: int) -> void:
	var senderName: String = Characters.getCharacterResource(from).getCharacterName()
	var usedText: String = "[b]" + senderName + "[/b]: " + text
	chatHistory.text += "\n" + usedText



# ---------- SENDING MESSAGES -----------

# called to send a message
func sendMessage(text: String) -> void:
	# if the message is only empty characters, don't send it
	if isEmpty(text):
		return
	var processedText: String = processText(text)
	#TODO: maybe first show the message gray and make it white once came back from server
	#displayMessage(processedText, Connections.getMyId())
	Connections.queueDataToSend("meeting-chat", processedText, -1)
	

# process message text to remove any illegal characters
# 	this would also be where we could implement a censoring system if we wanted to
func processText(text: String) -> String:
	if removeLineBreaks:
		# remove all line breaks from the message
		for breakChar in breakChars:
			text.replace(breakChar, "")
	return text

#tests if the string is full of empty chars, like tabs and spaces
func isEmpty(inputStr: String) -> bool:
	var emptyCount: int = 0
	for i in emptyChars:
		emptyCount += inputStr.count(i)
	return inputStr.length() == emptyCount

func hasLineBreaks(inputStr):
	for i in breakChars:
		if inputStr.count(i) != inputStr.count("\\" + i):
			return true
	return false

func _on_LineEdit_text_entered(new_text: String) -> void:
	sendMessage(new_text)
	lineEdit.text = ""

func _on_Button_pressed() -> void:
	sendMessage(lineEdit.text)
	lineEdit.text = ""
