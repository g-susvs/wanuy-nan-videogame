extends CanvasLayer

const TITLE_FONT := preload("res://assets/fonts/PressStart2P.ttf")
const BODY_FONT := preload("res://assets/fonts/upheavtt.ttf")
const BUTTON_STYLE := preload("res://scenes/ui/button-style.tres")
const BUTTON_HOVER_STYLE := preload("res://scenes/ui/button-hover.tres")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	label.add_theme_font_override("font", TITLE_FONT)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(0.89385575, 0.6838279, 0.4475446, 1))
	vbox.add_child(label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	var button = Button.new()
	button.text = "Reiniciar"
	button.custom_minimum_size = Vector2(200, 50)
	button.add_theme_font_override("font", BODY_FONT)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	button.add_theme_color_override("font_hover_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	button.add_theme_color_override("font_focus_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	button.add_theme_stylebox_override("normal", BUTTON_STYLE)
	button.add_theme_stylebox_override("hover", BUTTON_HOVER_STYLE)
	button.add_theme_stylebox_override("pressed", BUTTON_HOVER_STYLE)
	button.add_theme_stylebox_override("hover_pressed", BUTTON_HOVER_STYLE)
	button.pressed.connect(_on_button_pressed)
	vbox.add_child(button)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer2)

	var quit_button = Button.new()
	quit_button.text = "Salir"
	quit_button.custom_minimum_size = Vector2(200, 50)
	quit_button.add_theme_font_override("font", BODY_FONT)
	quit_button.add_theme_font_size_override("font_size", 24)
	quit_button.add_theme_color_override("font_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	quit_button.add_theme_color_override("font_hover_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	quit_button.add_theme_color_override("font_pressed_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	quit_button.add_theme_color_override("font_focus_color", Color(0.80784315, 0.7176471, 0.62352943, 1))
	quit_button.add_theme_stylebox_override("normal", BUTTON_STYLE)
	quit_button.add_theme_stylebox_override("hover", BUTTON_HOVER_STYLE)
	quit_button.add_theme_stylebox_override("pressed", BUTTON_HOVER_STYLE)
	quit_button.add_theme_stylebox_override("hover_pressed", BUTTON_HOVER_STYLE)
	quit_button.pressed.connect(_on_quit_button_pressed)
	vbox.add_child(quit_button)

func show_game_over() -> void:
	visible = true
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()