class_name DungeonGenerator
extends Node2D


const ROOM_SCENE := preload("res://dungeon/rooms/Room.tscn")


# ==================================================
# DUNGEON SETTINGS
# ==================================================

@export_category("Dungeon Size")

@export_range(2, 100, 1)
var total_rooms: int = 20


@export_category("Boss")

@export_range(2, 50, 1)
var boss_rooms: int = 6


@export_category("Special Rooms")

@export_range(0, 20, 1)
var reward_rooms: int = 2


@export_range(0, 20, 1)
var exploration_rooms: int = 2


@export_range(0, 20, 1)
var special_rooms: int = 1


@export_category("Room Layout")

@export var room_spacing: Vector2 = Vector2(700, 420)


# ==================================================
# VARIABLES
# ==================================================

var occupied: Dictionary = {}

var generated_rooms: Array[DungeonRoom] = []

var main_path: Array[Vector2i] = []

var side_room_positions: Array[Vector2i] = []


# ==================================================
# START
# ==================================================

func _ready() -> void:

	randomize()

	generate_dungeon()


# ==================================================
# GENERATE DUNGEON
# ==================================================

func generate_dungeon() -> void:

	occupied.clear()

	generated_rooms.clear()

	main_path.clear()

	side_room_positions.clear()


	# Remove old rooms
	for child in get_children():

		if child is DungeonRoom:

			child.queue_free()


	# ==================================================
	# CHECK SETTINGS
	# ==================================================

	var minimum_required_rooms: int = boss_rooms


	if total_rooms < minimum_required_rooms:

		total_rooms = minimum_required_rooms


	var special_room_count: int = (
		reward_rooms
		+ exploration_rooms
		+ special_rooms
	)


	if special_room_count > total_rooms - minimum_required_rooms:

		print("WARNING: Too many special rooms for this dungeon size.")

		print(
			"Reduce Reward/Exploration/Special rooms "
			+ "or increase Total Rooms."
		)

		return


	# ==================================================
	# 1. CREATE START
	# ==================================================

	var start_position: Vector2i = Vector2i.ZERO

	var start_room: DungeonRoom = create_room(start_position)


	if start_room == null:

		print("ERROR: Could not create START room.")

		return


	start_room.room_type = DungeonRoom.RoomType.START

	main_path.append(start_position)


	# ==================================================
	# 2. CREATE BOSS PATH
	# ==================================================

	var current_position: Vector2i = start_position


	for i in range(boss_rooms - 1):

		var possible_positions: Array[Vector2i] = []


		for direction in get_directions():

			var candidate_position: Vector2i = (
				current_position + direction
			)


			if occupied.has(candidate_position):

				continue


			possible_positions.append(candidate_position)


		if possible_positions.is_empty():

			print("ERROR: Could not create boss path.")

			return


		var new_position: Vector2i = (
			possible_positions.pick_random()
		)


		create_room(new_position)

		main_path.append(new_position)

		current_position = new_position


	# ==================================================
	# 3. ASSIGN MAIN PATH
	# ==================================================

	# START
	var start_path_room: DungeonRoom = (
		occupied[main_path[0]]
	)

	start_path_room.room_type = (
		DungeonRoom.RoomType.START
	)


	# COMBAT
	for i in range(1, main_path.size() - 1):

		var path_position: Vector2i = main_path[i]

		var path_room: DungeonRoom = (
			occupied[path_position]
		)

		path_room.room_type = (
			DungeonRoom.RoomType.COMBAT
		)


	# BOSS
	var boss_position: Vector2i = (
		main_path[main_path.size() - 1]
	)

	var boss_room: DungeonRoom = (
		occupied[boss_position]
	)

	boss_room.room_type = (
		DungeonRoom.RoomType.BOSS
	)


	# ==================================================
	# 4. CREATE SIDE ROOMS
	# ==================================================

	while generated_rooms.size() < total_rooms:

		var possible_positions: Array[Vector2i] = []


		for existing_position in occupied.keys():

			var grid_position: Vector2i = (
				existing_position
			)


			for direction in get_directions():

				var new_position: Vector2i = (
					grid_position + direction
				)


				if occupied.has(new_position):

					continue


				if possible_positions.has(new_position):

					continue


				possible_positions.append(new_position)


		if possible_positions.is_empty():

			print("ERROR: No more positions available.")

			break


		var new_room_position: Vector2i = (
			possible_positions.pick_random()
		)


		var new_room: DungeonRoom = (
			create_room(new_room_position)
		)


		if new_room == null:

			break


		side_room_positions.append(
			new_room_position
		)


		# Default side rooms to COMBAT
		new_room.room_type = (
			DungeonRoom.RoomType.COMBAT
		)


	# ==================================================
	# 5. ASSIGN REWARD ROOMS
	# ==================================================

	var side_index: int = 0


	for i in range(reward_rooms):

		if side_index >= side_room_positions.size():

			break


		var reward_position: Vector2i = (
			side_room_positions[side_index]
		)


		var reward_room: DungeonRoom = (
			occupied[reward_position]
		)


		reward_room.room_type = (
			DungeonRoom.RoomType.REWARD
		)


		side_index += 1


	# ==================================================
	# 6. ASSIGN EXPLORATION ROOMS
	# ==================================================

	for i in range(exploration_rooms):

		if side_index >= side_room_positions.size():

			break


		var exploration_position: Vector2i = (
			side_room_positions[side_index]
		)


		var exploration_room: DungeonRoom = (
			occupied[exploration_position]
		)


		exploration_room.room_type = (
			DungeonRoom.RoomType.EXPLORATION
		)


		side_index += 1


	# ==================================================
	# 7. ASSIGN SPECIAL ROOMS
	# ==================================================

	for i in range(special_rooms):

		if side_index >= side_room_positions.size():

			break


		var special_position: Vector2i = (
			side_room_positions[side_index]
		)


		var special_room: DungeonRoom = (
			occupied[special_position]
		)


		special_room.room_type = (
			DungeonRoom.RoomType.SPECIAL
		)


		side_index += 1


	# ==================================================
	# 8. CONNECT ROOMS
	# ==================================================

	connect_rooms()


	# ==================================================
	# 9. PRINT RESULT
	# ==================================================

	print_dungeon_info()


# ==================================================
# CREATE ROOM
# ==================================================

func create_room(
	grid_position: Vector2i
) -> DungeonRoom:

	if occupied.has(grid_position):

		return null


	var room: DungeonRoom = (
		ROOM_SCENE.instantiate() as DungeonRoom
	)


	if room == null:

		print(
			"ERROR: Room.tscn is not a DungeonRoom."
		)

		return null


	add_child(room)


	room.position = Vector2(
		grid_position.x * room_spacing.x,
		grid_position.y * room_spacing.y
	)


	occupied[grid_position] = room

	generated_rooms.append(room)


	return room


# ==================================================
# CONNECT ROOMS
# ==================================================

func connect_rooms() -> void:

	for grid_position in occupied.keys():

		var room: DungeonRoom = (
			occupied[grid_position]
		)


		for direction in get_directions():

			var neighbor_position: Vector2i = (
				grid_position + direction
			)


			if occupied.has(neighbor_position):

				room.set_connection(direction)


# ==================================================
# DIRECTIONS
# ==================================================

func get_directions() -> Array[Vector2i]:

	return [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]


# ==================================================
# DEBUG OUTPUT
# ==================================================

func print_dungeon_info() -> void:

	print("")

	print("==============================")

	print("DUNGEON GENERATED")

	print("==============================")


	print(
		"TOTAL ROOMS: ",
		generated_rooms.size()
	)


	print(
		"BOSS DISTANCE: ",
		boss_rooms
	)


	print(
		"MAIN PATH ROOMS: ",
		main_path.size()
	)


	print(
		"SIDE ROOMS: ",
		side_room_positions.size()
	)


	print("")


	for grid_position in occupied.keys():

		var room: DungeonRoom = (
			occupied[grid_position]
		)


		var location: String = ""


		if main_path.has(grid_position):

			location = " [MAIN PATH]"

		elif side_room_positions.has(grid_position):

			location = " [SIDE ROOM]"


		print(
			grid_position,
			" -> ",
			get_room_type_name(room.room_type),
			location
		)


	print("==============================")

	print("")


# ==================================================
# ROOM TYPE NAME
# ==================================================

func get_room_type_name(room_type) -> String:

	match room_type:

		DungeonRoom.RoomType.START:

			return "START"


		DungeonRoom.RoomType.COMBAT:

			return "COMBAT"


		DungeonRoom.RoomType.EXPLORATION:

			return "EXPLORATION"


		DungeonRoom.RoomType.REWARD:

			return "REWARD"


		DungeonRoom.RoomType.SPECIAL:

			return "SPECIAL"


		DungeonRoom.RoomType.BOSS:

			return "BOSS"


	return "UNKNOWN"
