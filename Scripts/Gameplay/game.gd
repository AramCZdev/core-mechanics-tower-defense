extends Node2D

@onready var pause_animation = $"CanvasLayer/Bottom Panel/Pause Animation"
@onready var coin_counter = $"CanvasLayer/Coin Counter"
@onready var base_hp_label = $"CanvasLayer/Base HP"

enum TowerType {
	NORMAL,
	FAST,
	CANNON
}

const NORMAL_COST: int = 100
const FAST_COST: int = 200
const CANNON_COST: int = 300

const NORMAL_COST_HARD: int = 150
const FAST_COST_HARD: int = 300
const CANNON_COST_HARD: int = 400

var selected_tower: TowerType = TowerType.NORMAL
var coins: int = 300
var base_hp: int = 20
var max_base_hp: int = 20
var game_over: bool = false

func get_tower_cost(tower_type: int) -> int:
	var cost: int

	if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
		match tower_type:
			0:
				cost = NORMAL_COST_HARD
			1:
				cost = FAST_COST_HARD
			2:
				cost = CANNON_COST_HARD
			_:
				cost = 0
	else:
		match tower_type:
			0:
				cost = NORMAL_COST
			1:
				cost = FAST_COST
			2:
				cost = CANNON_COST
			_:
				cost = 0

	return cost

func _ready() -> void:
	if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
		$CanvasLayer/Shop/VBoxContainer/NormalTowerButton.tooltip_text = "Normal Tower
Costs: 150$"
		$CanvasLayer/Shop/VBoxContainer/FastTowerButton.tooltip_text = "Fast Tower
Costs: 300$"
		$CanvasLayer/Shop/VBoxContainer/CanonButton.tooltip_text = "Cannon
Costs: 400$"
	else:
		$CanvasLayer/Shop/VBoxContainer/NormalTowerButton.tooltip_text = "Normal Tower
Costs: 100$"
		$CanvasLayer/Shop/VBoxContainer/FastTowerButton.tooltip_text = "Fast Tower
Costs: 200$"
		$CanvasLayer/Shop/VBoxContainer/CanonButton.tooltip_text = "Cannon
Costs: 300$"

func _process(_delta: float) -> void:
	coin_counter.text = str(coins, "$")
	base_hp_label.text = str("Base: ", base_hp, "/", max_base_hp)

	if base_hp > max_base_hp * 0.5:
		base_hp_label.add_theme_color_override("font_color", Color.WHITE)
	elif base_hp > max_base_hp * 0.25:
		base_hp_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		base_hp_label.add_theme_color_override("font_color", Color.RED)

func take_base_damage(amount: int) -> void:
	base_hp -= amount
	if base_hp <= 0:
		base_hp = 0
		game_over = true

func _on_normal_tower_button_pressed() -> void:
	selected_tower = TowerType.NORMAL
	print("Selected Normal Tower")


func _on_fast_tower_button_pressed() -> void:
	selected_tower = TowerType.FAST
	print("Selected Fast Tower")


func _on_canon_button_pressed() -> void:
	selected_tower = TowerType.CANNON
	print("Selected Canon")

func get_selected_tower_cost() -> int:
	var cost: int

	match selected_tower:
		0:
			cost = NORMAL_COST
		1:
			cost = FAST_COST
		2:
			cost = CANNON_COST
		_:
			cost = 0

	if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
		match selected_tower:
			0:
				cost = NORMAL_COST_HARD
			1:
				cost = FAST_COST_HARD
			2:
				cost = CANNON_COST_HARD
			_:
				cost = 0

	print("Selected tower: ", selected_tower)
	print("Game mode: ", SettingsManager.game_mode)
	print("Tower cost: ", cost)

	return cost


func _on_pause_pressed() -> void:
	pause_animation.play("pause")
	get_tree().paused = true
	$"CanvasLayer/Bottom Panel/Action Text".text = "Paused"


func _on_resume_pressed() -> void:
	pause_animation.play("resume")
	get_tree().paused = false
	$"CanvasLayer/Bottom Panel/Action Text".text = ""


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/Main.tscn")
