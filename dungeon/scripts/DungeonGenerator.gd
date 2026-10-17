
class_name DungeonGenerator
extends Node2D


# ==================================================
# ROOM SCENES
# ==================================================

const START_ROOMS: Array[PackedScene] = [
	preload("res://dungeon/rooms/Start/CaveStart1.tscn")
]

const COMBAT_ROOMS: Array[PackedScene] = [
	preload("res://dungeon/rooms/Combat/CaveCombat1.tscn")
]

const EXPLORATION_ROOMS: Array[PackedScene] = [
	preload("res://dungeon/rooms/Exploration/CaveExploration1.tscn")
]

const REWARD_ROOMS: Array[PackedScene] = [
	# preload("res://dungeon/rooms/Reward/CaveReward1.tscn")
]

const SPECIAL_ROOMS: Array[PackedScene] = [
	# preload("res://dungeon/rooms/Special/CaveSpecial1.tscn")
]

const BOSS_ROOMS: Array[PackedScene] = [
	preload("res://dungeon/rooms/Boss/CaveBoss1.tscn")
]


# ==================================================
# SETTINGS
# ==================================================

@export_category("Boss Path")

@export_range(2, 50, 1)
var rooms_to_boss: int = 5

@export_category("Room Types")

@export_range(0, 20, 1)
var reward_rooms: int = 2

@export_range(0, 20, 1)
var exploration_rooms: int = 2

@export_category("Generation")

@export_range(1, 1000, 1)
var generation_attempts: int = 100

@export var generate_on_ready: bool = true

@export_range(0, 1000, 1)
var player_z_index: int = 100


# ==================================================
# DATA
# ==================================================

var occupied: Dictionary = {}
var main_path: Array[DungeonRoom] = []
var side_room_: Array[DungeonRoom] = []

var start_room: DungeonRoom


# ==================================================
# INITIALIZATION
# ==================================================

func _ready() -> void:
	if generate_on_ready:
		generate_dungeon()


# ==================================================
# GENERATE DUNGEON WITH RETRIES
# ==================================================

func generate_dungeon() -> void:
	clear_dungeon()
	
	if START_ROOMS.is_empty() or BOSS_ROOMS.is_empty():
		push_error("DungeonGenerator: Start or boss scenes are missing.")
		return

	if COMBAT_ROOMS.is_empty():
		push_error("DungeonGenerator: Combat room scenes are missing.")
		return

	var middle_count: int = rooms_to_boss - 2
	var room_types: Array[String] = create_middle_room_types(
		middle_count
	)
	room_types.append("boss")

	for attempt in range(generation_attempts):
		clear_dungeon()

		var starts: Array[PackedScene] = START_ROOMS.duplicate()
		starts.shuffle()

		for scene in starts:
			var candidate_start := scene.instantiate() as DungeonRoom

			if candidate_start == null:
				push_error("Start scene root must be a DungeonRoom.")
				continue

			add_child(candidate_start)
			candidate_start.position = Vector2.ZERO

			if not has_valid_room_bounds(candidate_start):
				candidate_start.free()
				push_error(
					"Every room needs a RoomBounds RectangleShape2D."
				)
				continue

			start_room = candidate_start
			main_path.append(start_room)
			occupied[start_room] = true

			if build_path(start_room, "", room_types, 0):
				print(
					"Dungeon generated successfully on attempt ",
					attempt + 1,
					". Rooms: ",
					main_path.size()
				)
				return

			clear_dungeon()

	print(
		"Could not generate a valid dungeon after ",
		generation_attempts,
		" attempts. Check room entrances, bounds, and room scenes."
	)


# ==================================================
# BUILD CONNECTED PATH
# ==================================================

func build_path(
	current_room: DungeonRoom,
	incoming_entrance: String,
	room_types: Array[String],
	room_index: int
) -> bool:

	if room_index >= room_types.size():
		return true

	var exits: Array[String] = []

	for entrance_name in get_entrance_names():
		if entrance_name == incoming_entrance:
			continue

		if get_entrance(current_room, entrance_name) != null:
			exits.append(entrance_name)

	exits.shuffle()

	var scenes: Array[PackedScene] = get_room_list(
		room_types[room_index]
	)

	if scenes.is_empty():
		return false

	for exit_name in exits:
		var exit_marker := get_entrance(current_room, exit_name)

		if exit_marker == null:
			continue

		var target_position := exit_marker.global_position
		var opposite_name := get_opposite_entrance(exit_name)

		var shuffled_scenes: Array[PackedScene] = scenes.duplicate()
		shuffled_scenes.shuffle()

		for scene in shuffled_scenes:
			var candidate := scene.instantiate() as DungeonRoom

			if candidate == null:
				continue

			add_child(candidate)

			if not has_valid_room_bounds(candidate):
				candidate.free()
				continue

			var entrance := get_entrance(candidate, opposite_name)

			if entrance == null:
				candidate.free()
				continue

			# Align the two entrance markers exactly.
			candidate.global_position += (
				target_position - entrance.global_position
			)

			# Reject this room if it overlaps any placed room.
			if overlaps_existing_room(candidate):
				candidate.free()
				continue

			occupied[candidate] = true
			main_path.append(candidate)

			if build_path(
				candidate,
				opposite_name,
				room_types,
				room_index + 1
			):
				return true

			# This branch cannot reach the boss.
			main_path.erase(candidate)
			occupied.erase(candidate)
			candidate.free()

	return false


# ==================================================
# ROOM BOUNDS
# ==================================================

func get_room_bounds(room: DungeonRoom) -> Rect2:
	var bounds := room.find_child(
		"RoomBounds",
		true,
		false
	) as CollisionShape2D

	if bounds == null:
		return Rect2()

	var rectangle := bounds.shape as RectangleShape2D

	if rectangle == null:
		return Rect2()

	# Assumes rooms are not rotated.
	var size := rectangle.size * bounds.global_scale.abs()
	var center := bounds.global_position

	return Rect2(center - size / 2.0, size)


func has_valid_room_bounds(room: DungeonRoom) -> bool:
	var bounds := room.find_child(
		"RoomBounds",
		true,
		false
	) as CollisionShape2D

	if bounds == null:
		return false

	var rectangle := bounds.shape as RectangleShape2D

	if rectangle == null:
		return false

	return rectangle.size.x > 0.0 and rectangle.size.y > 0.0


func overlaps_existing_room(candidate: DungeonRoom) -> bool:
	var candidate_bounds := get_room_bounds(candidate)

	for existing in occupied.keys():
		var room := existing as DungeonRoom

		if room == null or not is_instance_valid(room):
			continue

		var existing_bounds := get_room_bounds(room)

		# Edge-to-edge contact is allowed.
		if candidate_bounds.intersects(existing_bounds):
			return true

	return false


# ==================================================
# ENTRANCE MARKERS
# ==================================================

func get_entrance_names() -> Array[String]:
	return [
		"EntranceTop",
		"EntranceBottom",
		"EntranceLeft",
		"EntranceRight"
	]


func get_entrance(room: DungeonRoom, entrance_name: String) -> Marker2D:
	var marker = room.find_child(entrance_name, true, false) as Marker2D
	return marker



func get_opposite_entrance(entrance_name: String) -> String:
	match entrance_name:
		"EntranceTop":
			return "EntranceBottom"
		"EntranceBottom":
			return "EntranceTop"
		"EntranceLeft":
			return "EntranceRight"
		"EntranceRight":
			return "EntranceLeft"

	return ""


# ==================================================
# ROOM TYPES
# ==================================================

func create_middle_room_types(
	middle_count: int
) -> Array[String]:
	var types: Array[String] = []

	var rewards_to_place: int = mini(reward_rooms, middle_count)
	var exploration_to_place: int = mini(
		exploration_rooms,
		middle_count - rewards_to_place
	)

	for i in range(rewards_to_place):
		if not REWARD_ROOMS.is_empty():
			types.append("reward")

	for i in range(exploration_to_place):
		if not EXPLORATION_ROOMS.is_empty():
			types.append("exploration")

	while types.size() < middle_count:
		types.append("combat")

	types.shuffle()
	return types


func get_room_list(room_type: String) -> Array[PackedScene]:
	match room_type:
		"reward":
			return REWARD_ROOMS
		"exploration":
			return EXPLORATION_ROOMS
		"special":
			return SPECIAL_ROOMS
		"boss":
			return BOSS_ROOMS
		"combat":
			return COMBAT_ROOMS

	return COMBAT_ROOMS


# ==================================================
# CLEAR DUNGEON
# ==================================================

func clear_dungeon() -> void:
	for child in get_children():
		child.free()

	occupied.clear()
	main_path.clear()
	side_room_.clear()
	start_room = null
