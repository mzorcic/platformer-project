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


var room_type: RoomType = RoomType.COMBAT:
	set(value):
		room_type = value
		queue_redraw()


var connected_top: bool = false
var connected_bottom: bool = false
var connected_left: bool = false
var connected_right: bool = false


func _ready() -> void:
	queue_redraw()


# ==================================================
# MARKERS
# ==================================================

func get_marker(direction: Vector2i) -> Marker2D:

	var marker_name: String = ""

	match direction:

		Vector2i.UP:
			marker_name = "EntranceTop"

		Vector2i.DOWN:
			marker_name = "EntranceBottom"

		Vector2i.LEFT:
			marker_name = "EntranceLeft"

		Vector2i.RIGHT:
			marker_name = "EntranceRight"

		_:
			return null


	return get_node_or_null(marker_name) as Marker2D


func has_marker(direction: Vector2i) -> bool:

	return get_marker(direction) != null


# ==================================================
# CONNECTION
# ==================================================

func set_connection(direction: Vector2i) -> void:

	if direction == Vector2i.UP:
		connected_top = true

	elif direction == Vector2i.DOWN:
		connected_bottom = true

	elif direction == Vector2i.LEFT:
		connected_left = true

	elif direction == Vector2i.RIGHT:
		connected_right = true

	queue_redraw()


# ==================================================
# DRAW
# ==================================================

func _draw() -> void:

	var rect := Rect2(-room_size / 2.0, room_size)

	var room_color := Color(0.15, 0.15, 0.15)


	match room_type:

		DungeonRoom.RoomType.START:
			room_color = Color(0.1, 0.35, 0.1)

		DungeonRoom.RoomType.COMBAT:
			room_color = Color(0.25, 0.15, 0.15)

		DungeonRoom.RoomType.EXPLORATION:
			room_color = Color(0.15, 0.25, 0.35)

		DungeonRoom.RoomType.REWARD:
			room_color = Color(0.35, 0.3, 0.1)

		DungeonRoom.RoomType.SPECIAL:
			room_color = Color(0.3, 0.15, 0.35)

		DungeonRoom.RoomType.BOSS:
			room_color = Color(0.4, 0.05, 0.05)


	draw_rect(rect, room_color)
	draw_rect(rect, Color(0.7, 0.7, 0.7), false, 4.0)


	# Draw connection indicators.

	if connected_top:
		draw_rect(
			Rect2(
				Vector2(-40, -room_size.y / 2.0 - 4),
				Vector2(80, 8)
			),
			Color.GREEN
		)

	if connected_bottom:
		draw_rect(
			Rect2(
				Vector2(-40, room_size.y / 2.0 - 4),
				Vector2(80, 8)
			),
			Color.GREEN
		)

	if connected_left:
		draw_rect(
			Rect2(
				Vector2(-room_size.x / 2.0 - 4, -40),
				Vector2(8, 80)
			),
			Color.GREEN
		)

	if connected_right:
		draw_rect(
			Rect2(
				Vector2(room_size.x / 2.0 - 4, -40),
				Vector2(8, 80)
			),
			Color.GREEN
		)
