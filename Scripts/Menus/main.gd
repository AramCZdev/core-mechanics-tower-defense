extends Control

@onready var main_menu = $Menu
@onready var play_menu = $Difficulty
@onready var settings_menu = $Settings

func _ready() -> void:
	play_menu.visible = false
	main_menu.visible = true
	settings_menu.visible = false
	$"Settings/Other/Health Bars".button_pressed = SettingsManager.get_setting("health_bar", true)

func _on_play_pressed() -> void:
	play_menu.visible = true
	main_menu.visible = false


func _on_normal_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/Game.tscn")


func _on_back_pressed() -> void:
	play_menu.visible = false
	main_menu.visible = true
	settings_menu.visible = false


func _on_settings_pressed() -> void:
	settings_menu.visible = true
	main_menu.visible = false


func _on_health_bars_toggled(toggled_on: bool) -> void:
	SettingsManager.set_setting("health_bar", toggled_on)
