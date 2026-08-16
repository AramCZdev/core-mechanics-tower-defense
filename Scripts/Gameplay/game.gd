extends Node2D

@onready var coin_counter = $"CanvasLayer/Coin Counter"

enum TowerType {
	NORMAL,
	FAST,
	CANON
}

const NORMAL_COST: int = 100
const FAST_COST: int = 150
const CANON_COST: int = 200

var selected_tower: TowerType = TowerType.NORMAL
var coins: int = 300

func _process(_delta: float) -> void:
	coin_counter.text = str(coins)

func _on_normal_tower_button_pressed() -> void:
	selected_tower = TowerType.NORMAL
	print("Selected Normal Tower")


func _on_fast_tower_button_pressed() -> void:
	selected_tower = TowerType.FAST
	print("Selected Fast Tower")


func _on_canon_button_pressed() -> void:
	selected_tower = TowerType.CANON
	print("Selected Canon")

func get_selected_tower_cost() -> int:
	match selected_tower:
		TowerType.NORMAL:
			return NORMAL_COST
		TowerType.FAST:
			return FAST_COST
		TowerType.CANON:
			return CANON_COST

	return 0
