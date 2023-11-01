extends Control

@export var radius: float = 1:
	set(value):
		radius = value
		redraw_points()
@export var region_size: Vector2 = Vector2(64, 64):
	set(value):
		region_size = value
		negation_zone_center = region_size / 2
		redraw_points()
@export var samples: int = 30:
	set(value):
		samples = value
		redraw_points()

var points_to_draw: PackedVector2Array
var negation_zone_center: Vector2 = Vector2.ZERO
@export var negation_zone_radius: int = 64


func _ready():
	redraw_points()


func _draw():
	if points_to_draw:
		for point in points_to_draw:
			draw_circle(point, 1, Color.WHITE)
	# Negation Zone edge
	draw_circle_donut_poly(negation_zone_center, negation_zone_radius, negation_zone_radius + 2, 0, 360, Color.ORANGE)
	# Negation Zone backfill
	draw_circle_donut_poly(negation_zone_center, negation_zone_radius, 500, 0, 360, Color(1, 0, 0, 0.5))


func _process(_delta):
	queue_redraw()


func redraw_points() -> void:
	points_to_draw = generate_points(radius, region_size, samples)





func generate_points(radius: float, sample_region_size: Vector2, num_samples_before_rejection: int = 30) -> PackedVector2Array:
	var cell_size = radius / sqrt(2)
	# Generate a 2D array for the grid
	var grid: Array = []
	for i in range(ceil(sample_region_size.x / cell_size)): 
		grid.append([])
		for j in range(ceil(sample_region_size.y / cell_size)): 
			grid[i].append(0)

	var points: PackedVector2Array = []
	var spawn_points: PackedVector2Array = []

	spawn_points.append(sample_region_size / 2)
	while spawn_points.size() > 0:
		var spawn_index: int = randi_range(0, spawn_points.size() - 1)
		var spawn_center: Vector2 = spawn_points[spawn_index]

		var candidate_accepted: bool = false
		for i in range(0, num_samples_before_rejection):
			var angle: float = randf() * PI * 2
			var dir := Vector2(sin(angle), cos(angle))
			var candidate: Vector2 = spawn_center + dir * randf_range(radius, radius * 2)
			if is_valid(candidate, sample_region_size, cell_size, radius, points, grid):
				points.append(candidate)
				spawn_points.append(candidate)
				grid[int(candidate.x / cell_size)][int(candidate.y / cell_size)] = points.size()
				candidate_accepted = true
				break
		if not candidate_accepted:
			spawn_points.remove_at(spawn_index)

	return points


func is_valid(
	candidate: Vector2, sample_region_size: Vector2, cell_size: float, 
	radius: float, points: PackedVector2Array, grid: Array
) -> bool:
#	if Geometry2D.is_point_in_circle(candidate, Vector2.ZERO, negation_zone_radius):
	if candidate.x >= 0 and candidate.x < sample_region_size.x and \
	candidate.y >= 0 and candidate.y < sample_region_size.y:
		var cell_x = int(candidate.x / cell_size)
		var cell_y = int(candidate.y / cell_size)
		var search_start_x: int = max(0, cell_x - 2)
		var search_end_x: int = min(cell_x + 2, ceil(sample_region_size.x / cell_size - 1))
		var search_start_y: int = max(0, cell_y - 2)
		var search_end_y: int = min(cell_y + 2, ceil(sample_region_size.y / cell_size - 1))

		for x in range(search_start_x, search_end_x):
			for y in range(search_start_y, search_end_y):
				var point_index = grid[x][y] - 1
				if point_index != -1:
					var sqr_dst: float = (candidate - points[point_index]).length_squared()
					if sqr_dst < radius**2:
						return false
		return true

	return false
		

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)


func draw_circle_donut_poly(center, inner_radius, outer_radius, angle_from, angle_to, color):  
	var nb_points = 32  
	var points_arc = PackedVector2Array()  
	var points_arc2 = PackedVector2Array()  
	var colors = PackedColorArray([color])  

	for i in range(nb_points+1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg_to_rad(angle_point)), sin(deg_to_rad(angle_point))) * outer_radius)  
	for i in range(nb_points,-1,-1):  
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90  
		points_arc.push_back(center + Vector2(cos(deg_to_rad(angle_point)), sin(deg_to_rad(angle_point))) * inner_radius)  
	draw_polygon(points_arc, colors)  

