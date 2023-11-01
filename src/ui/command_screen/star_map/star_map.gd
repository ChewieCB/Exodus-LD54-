@tool
extends Control

@export_group("Poisson Disc")
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

@export_group("Starlane Generation")
@export var point_connection_range: float = 100
@export var max_point_connections: int = 100

@export_group("Negation Zone")
@export var negation_zone_radius: int = 64

var points_to_draw: PackedVector2Array
var adjacency_list = []
var negation_zone_center: Vector2 = Vector2.ZERO
var drawn_edges = []


func _ready():
	redraw_points()
	adjacency_list = generate_weighted_adjacency_list(points_to_draw)
	generate_edges(points_to_draw, adjacency_list)


func _draw():
	if points_to_draw:
		for point in points_to_draw:
			draw_circle(point, 4, Color.WHITE)
	# Negation Zone edge
	draw_circle_donut_poly(negation_zone_center, negation_zone_radius, negation_zone_radius + 2, 0, 360, Color.ORANGE)
	# Negation Zone backfill
	draw_circle_donut_poly(negation_zone_center, negation_zone_radius, 500, 0, 360, Color(1, 0, 0, 0.5))
	for edge in drawn_edges:
		draw_line(points_to_draw[edge[0]], points_to_draw[edge[1]], Color.GOLD, 1.0)
		# Draw the weight
		# FIXME
#		var default_font = ThemeDB.fallback_font
#		draw_string(default_font, points_to_draw[edge[1]] - points_to_draw[edge[0]], str(edge[2]), HORIZONTAL_ALIGNMENT_CENTER, -1, 4)


func _process(_delta):
	queue_redraw()


func redraw_points() -> void:
	points_to_draw = generate_points(radius, region_size, samples)


func generate_edges(points, _adjacency_list):
	for i in range(_adjacency_list.size() - 1):
		var node_a = _adjacency_list[i]
		for j in range(node_a.size() - 1):
			var node_b = node_a[j][0]
			var weight  = node_a[j][1]
			var edge = [i, node_b, weight]
			if edge in drawn_edges:
				continue
			# Declare an edge
			var point_a = points[i]
			var point_b = points[node_b]
			# Mark edge as drawn
			drawn_edges.append(edge)


func generate_weighted_adjacency_list(points: PackedVector2Array):
	# Generate a randomly weighted graph from the available points
	randomize()
	
	var num_points = points.size() - 1
	var _adjacency_list = []
	var weight_min = 0
	var weight_max = 20
	
	# Build the empty adjacency list to populate
	for i in range(num_points):
		_adjacency_list.append([])
	
	# Generate edge connections for 
	for i in range(_adjacency_list.size() - 1):
		# For now we connect every point to every other point with random weights.
		# We can look at randomly removing connections when this works.
		#
		# Limit the number of connections per point to prevent clustering
		if _adjacency_list[i].size() < max_point_connections:
			for j in range(num_points):
				# Don't connect points to themselves
				if j == i:
					continue
				# Only connect nearby points
				if points_to_draw[i].distance_to(points[j]) > point_connection_range:
					continue
				# Limit the number of connections per point to prevent clustering
				if _adjacency_list[j].size() >= max_point_connections:
					continue
				var random_weight = randi_range(weight_min, weight_max)
				_adjacency_list = graph_add_edge(_adjacency_list, i, j, random_weight)
				var DEBUG_size = _adjacency_list[i].size()
				var DEBUG_max_connections = max_point_connections
				if _adjacency_list[i].size() >= max_point_connections:
					break
	
	return _adjacency_list


func graph_add_edge(adjacency_list, node_a, node_b, weight):
	'''Create an edge within the adjacency list between node_a and node_b.'''
	adjacency_list[node_a].append([node_b, weight])
	adjacency_list[node_b].append([node_a, weight])
	return adjacency_list


func create_mst(points: PackedVector2Array):
#	var 
	pass


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

