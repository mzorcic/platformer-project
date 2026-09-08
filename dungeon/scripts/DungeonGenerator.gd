class_name DungeonGenerator
extends Node2D

const ROOM_SCENE := preload("res://dungeon/rooms/Room.tscn")

@export var min_rooms: int = 8
@export var max_rooms: int = 12

@export var room_spacing: Vector2 = Vector2(700, 420)

var occupied: Dictionary = {}
var generated_rooms: Array[DungeonRoom] = []


func _ready() -> void:
	generate_dungeon()


func generate_dungeon() -> void:
	# Remove previously generated rooms
	for child in get_children():
		child.queue_free()

	occupied.clear()
	generated_rooms.clear()

	# Start at the center of the grid
	var start_position := Vector2i.ZERO

	var start_room := create_room(start_position)

	if start_room != null:
		start_room.room_type = DungeonRoom.RoomType.START

	# Keep adding rooms until we reach the target
	var target_room_count: int = randi_range(min_rooms, max_rooms)

	while generated_rooms.size() < target_room_count:
		var possible_positions: Array[Vector2i] = []

		# Try adding a room next to any existing room
		for existing_position in occupied.keys():
			var grid_position: Vector2i = existing_position

			for direction in get_directions():
				var new_position: Vector2i = grid_position + direction

				if not occupied.has(new_position):
					possible_positions.append(new_position)

		# Safety check
		if possible_positions.is_empty():
			print("Could not create any more rooms.")
			break

		# Pick a random available position
		var new_room_position: Vector2i = possible_positions.pick_random()

		create_room(new_room_position)

	print("Dungeon generated!")
	print("Rooms: ", generated_rooms.size())
	print("Grid positions: ", occupied.keys())


func create_room(grid_position: Vector2i) -> DungeonRoom:
	if occupied.has(grid_position):
		return null

	var room := ROOM_SCENE.instantiate() as DungeonRoom

	if room == null:
		return null

	add_child(room)

	room.position = Vector2(
		grid_position.x * room_spacing.x,
		grid_position.y * room_spacing.y
	)

	occupied[grid_position] = room
	generated_rooms.append(room)

	return room


func get_directions() -> Array[Vector2i]:
	return [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]
