class_name Villager
extends Node2D
## A walking villager: goes to work, works, hauls the yield to storage, repeats.

enum Job { FARMER, KENNELER, WOODCUTTER }

enum State { TO_WORK, WORKING, TO_STORAGE }

const WALK_FRAMES := [
	preload("res://assets/sprites/villager_0.png"),
	preload("res://assets/sprites/villager_1.png"),
]

const WALK_SPEED := 55.0
const WORK_SECONDS := 4.0
## Resource delivered per completed cycle, by job.
const YIELD := {
	Job.FARMER: ["grain", 6],
	Job.KENNELER: ["fodder", 4],
	Job.WOODCUTTER: ["wood", 5],
}

var job: int = Job.FARMER
var workplace: Node2D
var storage: Node2D

var _state: int = State.TO_WORK
var _work_timer := 0.0
var _frame_timer := 0.0
var _frame := 0
var _sprite: Sprite2D


static func create(p_job: int, p_workplace: Node2D, p_storage: Node2D) -> Villager:
	var villager := Villager.new()
	villager.job = p_job
	villager.workplace = p_workplace
	villager.storage = p_storage
	return villager


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = WALK_FRAMES[0]
	_sprite.position = Vector2(0, -12)
	add_child(_sprite)


func _process(delta: float) -> void:
	delta *= GameState.time_scale
	match _state:
		State.TO_WORK:
			_walk_towards(workplace.global_position + Vector2(14, -6), delta)
		State.WORKING:
			_work_timer += delta
			_idle_bob(delta)
			if _work_timer >= WORK_SECONDS:
				_work_timer = 0.0
				_state = State.TO_STORAGE
		State.TO_STORAGE:
			_walk_towards(storage.global_position + Vector2(0, -8), delta)


func _walk_towards(target: Vector2, delta: float) -> void:
	var to_target := target - global_position
	var step := WALK_SPEED * delta
	if to_target.length() <= step:
		global_position = target
		if _state == State.TO_WORK:
			_state = State.WORKING
		else:
			_arrive_at_storage()
		return
	global_position += to_target.normalized() * step
	_animate_walk(delta, to_target.x < 0.0)


func _arrive_at_storage() -> void:
	var payload: Array = YIELD[job]
	GameState.add(payload[0], payload[1])
	_state = State.TO_WORK


func _animate_walk(delta: float, face_left: bool) -> void:
	_frame_timer += delta
	if _frame_timer >= 0.18:
		_frame_timer = 0.0
		_frame = (_frame + 1) % WALK_FRAMES.size()
		_sprite.texture = WALK_FRAMES[_frame]
	var bob := -1 if _frame == 0 else 1
	_sprite.position = Vector2(0, -12 + bob)
	_sprite.flip_h = face_left


func _idle_bob(delta: float) -> void:
	_sprite.position = Vector2(0, -12 + int(sin(_frame_timer * 9.0)) * 2)
	_frame_timer += delta
