extends Node2D
## Builds the village of Thondaimandalam: ground, buildings, villagers, HUD.
## Sprint 1: the settlement is alive — villagers work and haul yields.

const TILE_W := 64
const TILE_H := 32
const GRID_N := 22
const RIVER_COL := 15

const TEX := {
	"grass": preload("res://assets/sprites/tile_grass.png"),
	"dirt": preload("res://assets/sprites/tile_dirt.png"),
	"water": preload("res://assets/sprites/tile_water.png"),
	"sand": preload("res://assets/sprites/tile_sand.png"),
	"hut": preload("res://assets/sprites/hut.png"),
	"seat": preload("res://assets/sprites/seat.png"),
	"granary": preload("res://assets/sprites/granary.png"),
	"kennel": preload("res://assets/sprites/kennel.png"),
	"field": preload("res://assets/sprites/field.png"),
	"tree": preload("res://assets/sprites/tree.png"),
}

## tile -> Vector2i on the grid; offset raises the sprite so its base sits on the tile.
const BUILDINGS := {
	"seat": {"tile": Vector2i(7, 8), "offset": -46},
	"hut_a": {"tile": Vector2i(6, 6), "offset": -44},
	"hut_b": {"tile": Vector2i(9, 7), "offset": -44},
	"hut_c": {"tile": Vector2i(8, 10), "offset": -44},
	"granary": {"tile": Vector2i(6, 10), "offset": -44},
	"kennel_a": {"tile": Vector2i(5, 5), "offset": -44},
	"kennel_b": {"tile": Vector2i(10, 10), "offset": -44},
	"field_a": {"tile": Vector2i(4, 9), "offset": -6},
	"field_b": {"tile": Vector2i(9, 4), "offset": -6},
	"tree_a": {"tile": Vector2i(3, 4), "offset": -30},
	"tree_b": {"tile": Vector2i(4, 3), "offset": -30},
	"tree_c": {"tile": Vector2i(3, 6), "offset": -30},
	"tree_d": {"tile": Vector2i(11, 3), "offset": -30},
}

@onready var camera: Camera2D = $Camera

var _ground := Node2D.new()
var _entities := Node2D.new()
var _hud := CanvasLayer.new()
var _resource_labels := {}
var _date_label := Label.new()


func _ready() -> void:
	_ground.name = "Ground"
	_entities.name = "Entities"
	_entities.y_sort_enabled = true
	add_child(_ground)
	add_child(_entities)
	_build_ground()
	var granary := _build_buildings()
	_spawn_villagers(granary)
	_build_hud()
	GameState.resource_changed.connect(_on_resource_changed)
	GameState.date_changed.connect(_on_date_changed)


func tile_pos(i: int, j: int) -> Vector2:
	return Vector2((i - j) * TILE_W * 0.5, (i + j) * TILE_H * 0.5)


func _tile_kind(i: int, j: int) -> String:
	if j >= RIVER_COL:
		return "water"
	if j == RIVER_COL - 1:
		return "sand"
	if i == 7 or j == 7:
		return "dirt"
	return "grass"


func _build_ground() -> void:
	for i in GRID_N:
		for j in GRID_N:
			var sprite := Sprite2D.new()
			sprite.texture = TEX[_tile_kind(i, j)]
			sprite.position = tile_pos(i, j)
			_ground.add_child(sprite)


func _build_buildings() -> Sprite2D:
	var granary: Sprite2D = null
	for key: String in BUILDINGS:
		var def: Dictionary = BUILDINGS[key]
		var sprite := Sprite2D.new()
		sprite.texture = TEX[_texture_for(key)]
		sprite.offset = Vector2(0, def["offset"])
		sprite.position = tile_pos(def["tile"].x, def["tile"].y)
		_entities.add_child(sprite)
		if key == "granary":
			granary = sprite
	return granary


func _texture_for(key: String) -> String:
	if key.begins_with("hut_"):
		return "hut"
	if key.begins_with("granary"):
		return "granary"
	if key.begins_with("kennel"):
		return "kennel"
	if key.begins_with("field"):
		return "field"
	if key.begins_with("tree"):
		return "tree"
	return "seat"


func _spawn_villagers(granary: Sprite2D) -> void:
	var workplaces: Array = [
		[BUILDINGS["field_a"]["tile"], Villager.Job.FARMER],
		[BUILDINGS["field_b"]["tile"], Villager.Job.FARMER],
		[BUILDINGS["kennel_a"]["tile"], Villager.Job.KENNELER],
		[BUILDINGS["kennel_b"]["tile"], Villager.Job.KENNELER],
		[BUILDINGS["tree_a"]["tile"], Villager.Job.WOODCUTTER],
		[BUILDINGS["tree_c"]["tile"], Villager.Job.WOODCUTTER],
	]
	var seat: Vector2i = BUILDINGS["seat"]["tile"]
	for slot in workplaces:
		for _dup in 2:
			var work_node := Node2D.new()
			var wp: Vector2i = slot[0]
			work_node.position = tile_pos(wp.x, wp.y)
			_entities.add_child(work_node)
			var villager := Villager.create(slot[1], work_node, granary)
			villager.position = tile_pos(seat.x, seat.y) \
					+ Vector2(randf_range(-40, 40), randf_range(-10, 10))
			_entities.add_child(villager)


func _build_hud() -> void:
	add_child(_hud)
	var panel := PanelContainer.new()
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 12)
	pad.add_theme_constant_override("margin_top", 6)
	pad.add_theme_constant_override("margin_right", 12)
	pad.add_theme_constant_override("margin_bottom", 6)
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	pad.add_child(box)
	panel.add_child(pad)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_hud.add_child(panel)

	for resource: String in GameState.resources:
		var label := Label.new()
		label.text = "%s: %d" % [resource.capitalize(), GameState.resources[resource]]
		box.add_child(label)
		_resource_labels[resource] = label

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	_date_label.text = GameState.date_label()
	box.add_child(_date_label)

	var hint := Label.new()
	hint.text = "Drag to pan · Scroll to zoom"
	hint.modulate = Color(1, 1, 1, 0.55)
	_hud.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint.position = Vector2(12, -28)


func _on_resource_changed(resource: String, value: int) -> void:
	if _resource_labels.has(resource):
		_resource_labels[resource].text = "%s: %d" % [resource.capitalize(), value]


func _on_date_changed() -> void:
	_date_label.text = GameState.date_label()
