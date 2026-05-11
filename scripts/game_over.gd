extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # agregar esta línea al inicio del _ready()
	visible = false
	
	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0.75)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(color_rect)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.custom_minimum_size = Vector2(400, 160)
	vbox.offset_left = -200
	vbox.offset_right = 200
	vbox.offset_top = -80
	vbox.offset_bottom = 80
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)
	
	var label = Label.new()
	label.text = "GAME OVER"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # rojo
	vbox.add_child(label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	var button = Button.new()
	button.text = "Reiniciar"
	button.custom_minimum_size = Vector2(200, 50)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(_on_button_pressed)
	vbox.add_child(button)

func show_game_over() -> void:
	visible = true
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
