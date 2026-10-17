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


var connected_top: bool = false
var connected_bottom: bool = false
var connected_left: bool = false
var connected_right: bool = false


@onready var top_marker: Marker2D = $EntranceTop
@onready var bottom_marker: Marker2D = $EntranceBottom
@onready var left_marker: Marker2D = $EntranceLeft
@onready var right_marker: Marker2D = $EntranceRight


func set_connection(direction: Vector2i) -> void:

	if direction == Vector2i.UP:
		connected_top = true

	elif direction == Vector2i.DOWN:
		connected_bottom = true

	elif direction == Vector2i.LEFT:
		connected_left = true

	elif direction == Vector2i.RIGHT:
		connected_right = true


func get_marker(direction: Vector2i) -> Marker2D:

	if direction == Vector2i.UP:
		return top_marker

	if direction == Vector2i.DOWN:
		return bottom_marker

	if direction == Vector2i.LEFT:
		return left_marker

	if direction == Vector2i.RIGHT:
		return right_marker

	return null


func has_marker(direction: Vector2i) -> bool:
	return get_marker(direction) != null
