extends Area2D

signal bodyEntered
signal bodyExited

func _on_Gun_body_entered(body):
	for characterRes in Characters.getCharacterResources().values():
		if characterRes.getCharacterNode() == body:
			emit_signal("bodyEntered", characterRes)

func _on_Gun_body_exited(body):
	for characterRes in Characters.getCharacterResources().values():
		if characterRes.getCharacterNode() == body:
			emit_signal("bodyExited", characterRes)
