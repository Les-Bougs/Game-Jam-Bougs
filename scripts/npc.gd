extends AnimatedSprite2D

func _ready():
	hide()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_dialogue_line_changed)

func _on_dialogue_started(dialogue_resource):
	show()

func _on_dialogue_ended(dialogue_resource):
	hide()

func _on_dialogue_line_changed(line):
	if line.character == "Camarade":
		frame = 0
	elif line.character == "Patron":
		frame = 1
	else:
		frame = 2
