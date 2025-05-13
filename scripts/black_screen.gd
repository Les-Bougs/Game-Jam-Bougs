extends ColorRect


func fade_in() -> void:
	show()
	modulate.a = 0
	for i in 71:
		modulate.a = i/70.0
		await get_tree().create_timer(0.01).timeout

func fade_out() -> void:
	show()
	modulate.a = 1
	for i in 71:
		modulate.a = 1.0 - (i/70.0)
		await get_tree().create_timer(0.01).timeout
