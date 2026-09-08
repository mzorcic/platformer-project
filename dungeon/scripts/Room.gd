class_name DungeonRoom
extends Node2D

enum RoomType {
	START,
	COMBAT,
	EXPLORATION,
	REWARD,
	SPECIAL,
	BOSS
}

@export var room_size: Vector2 = Vector2(640, 360)

var room_type: RoomType = RoomType.COMBAT


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(
		-room_size / 2.0,
		room_size
	)

	draw_rect(rect, Color(0.15, 0.15, 0.15))
	draw_rect(rect, Color(0.7, 0.7, 0.7), false, 4.0)

	# Entrances
	draw_circle(Vector2(0, -180), 12.0, Color.GREEN)
	draw_circle(Vector2(0, 180), 12.0, Color.RED)
	draw_circle(Vector2(-320, 0), 12.0, Color.BLUE)
	draw_circle(Vector2(320, 0), 12.0, Color.YELLOW)
