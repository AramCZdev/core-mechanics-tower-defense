extends Node2D

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

var selected_tower: TowerType = TowerType.NORMAL
var coins: int = 300
var base_hp: int = 20
var max_base_hp: int = 20
var game_over: bool = false

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
	match selected_tower:
		TowerType.NORMAL:
			return NORMAL_COST
		TowerType.FAST:
			return FAST_COST
		TowerType.CANNON:
			return CANNON_COST

	return 0
