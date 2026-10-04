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


var connected_top: bool = false
var connected_bottom: bool = false
var connected_left: bool = false
var connected_right: bool = false


func _ready() -> void:
	pass


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


# ==================================================
# DRAW
# ==================================================
