extends Camera2D
## Drag to pan, mouse wheel to zoom. Fixed 2D view, CoC-style.

const ZOOM_MIN := 0.5
const ZOOM_MAX := 2.5

var _dragging := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom(1.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom(1.0 / 1.1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		position -= event.relative / zoom


func _apply_zoom(factor: float) -> void:
	var target := clampf(zoom.x * factor, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(target, target)
