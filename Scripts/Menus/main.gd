extends Control

@onready var main_menu = $Menu
@onready var play_menu = $Difficulty

func _ready() -> void:
	play_menu.visible = false
	main_menu.visible = true

func _on_play_pressed() -> void:
	play_menu.visible = true
	main_menu.visible = false


func _on_normal_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/Game.tscn")
