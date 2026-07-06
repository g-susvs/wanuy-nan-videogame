extends Control

const CONTROLS := [
	["Moverse a la izquierda", "A / ←"],
	["Moverse a la derecha", "D / →"],
	["Saltar", "Espacio"],
	["Ataque con lanza", "Tab"],
	["Ataque cuerpo a cuerpo", "Enter"],
	["Apuntar / lanzar honda", "Clic izquierdo (mantener y soltar)"],
]

const BODY_FONT := preload("res://assets/fonts/upheavtt.ttf")

func _ready() -> void:
	var container: VBoxContainer = %RowsContainer

	for entry in CONTROLS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)

		var action_label := Label.new()
		action_label.text = entry[0]
		action_label.custom_minimum_size = Vector2(300, 0)
		action_label.add_theme_font_override("font", BODY_FONT)
		action_label.add_theme_font_size_override("font_size", 18)
		action_label.add_theme_color_override("font_color", Color(1, 1, 1))
		row.add_child(action_label)

		var key_label := Label.new()
		key_label.text = entry[1]
		key_label.add_theme_font_override("font", BODY_FONT)
		key_label.add_theme_font_size_override("font_size", 18)
		key_label.add_theme_color_override("font_color", Color(0.89385575, 0.6838279, 0.4475446, 1))
		row.add_child(key_label)

		container.add_child(row)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
