@tool
extends Control

@export_group("Poisson Disc")
@export var circle_radius: float = 64:
	set(value):
		circle_radius = value
		redraw_points()
@export var poisson_radius: float = 50:
	set(value):
		poisson_radius = value
		redraw_points()
@export var retries: int = 30:
	set(value):
		retries = value
		redraw_points()

@export_group("Starlane Generation")
@export var point_connection_range: float = 100
@export var max_point_connections: int = 100

@export_group("Negation Zone")
@export var negation_zone_radius: int = 64:
	set(value):
		negation_zone_radius = value
		circle_radius = value
		redraw_points()

var points_to_draw: PackedVector2Array
var adjacency_list = []
var negation_zone_center: Vector2 = Vector2.ZERO
var drawn_edges = []

enum ShapeType {CIRCLE, POLYGON}
static var shape_info: Dictionary


func _ready():
	redraw_points()
#	adjacency_list = generate_weighted_adjacency_list(points_to_draw)
#	generate_edges(points_to_draw, adjacency_list)


func _draw():
	if points_to_draw:
		for point in points_to_draw:
			draw_circle(point, 2, Color.WHITE)
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
	points_to_draw = generate_points_for_circle(Vector2.ZERO, circle_radius, poisson_radius, retries)


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


static func generate_points_for_circle(circle_position: Vector2, circle_radius: float, poisson_radius: float, retries: int, start_point := Vector2.INF) -> PackedVector2Array:
	var sample_region_rect = Rect2(circle_position.x - circle_radius, circle_position.y - circle_radius, circle_radius * 2, circle_radius * 2)
	if start_point.x == INF:
		var angle: float = 2 * PI * randf()
		start_point = circle_position + Vector2(cos(angle), sin(angle)) * circle_radius * randf()
	elif not Geometry2D.is_point_in_circle(start_point, circle_position, circle_radius):
		push_error("Starting point ", start_point, " is not a valid point inside the circle!")
		return PackedVector2Array()
	
	shape_info[ShapeType.CIRCLE] = {
		"circle_position": circle_position,
		"circle_radius": circle_radius
	}
	
	return _generate_points(ShapeType.CIRCLE, sample_region_rect, poisson_radius, retries, start_point)


static func _generate_points(shape: int, sample_region_rect: Rect2, poisson_radius: float, retries: int, start_pos: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	points.clear()
	var cell_size: float = poisson_radius / sqrt(2)
	var cols: int = max(floor(sample_region_rect.size.x / cell_size), 1)
	var rows: int = max(floor(sample_region_rect.size.y / cell_size), 1)
	
	# scale the cell size in each axis
	var cell_size_scaled: Vector2
	cell_size_scaled.x = sample_region_rect.size.x / cols 
	cell_size_scaled.y = sample_region_rect.size.y / rows
	
	# use tranpose to map points starting from origin to calculate grid position
	var transpose = -sample_region_rect.position
	
	var grid: Array = []
	for i in cols:
		grid.append([])
		for j in rows:
			grid[i].append(-1)
	
	var spawn_points: Array = []
	spawn_points.append(start_pos)
	
	while spawn_points.size() > 0:
		var spawn_index: int = randi() % spawn_points.size()
		var spawn_centre: Vector2 = spawn_points[spawn_index]
		var sample_accepted: bool = false
		for i in retries:
			var angle: float = 2 * PI * randf()
			var sample: Vector2 = spawn_centre + Vector2(cos(angle), sin(angle)) * (poisson_radius + poisson_radius * randf())
			if _is_point_in_sample_region(sample, shape):
				if _is_valid_sample(shape, sample, transpose, cell_size_scaled, cols, rows, grid, points, poisson_radius):
					grid[int((transpose.x + sample.x) / cell_size_scaled.x)][int((transpose.y + sample.y) / cell_size_scaled.y)] = points.size()
					points.append(sample)
					spawn_points.append(sample)
					sample_accepted = true
					break
		if not sample_accepted and points.size() > 0:
			spawn_points.remove_at(spawn_index)
	return points


static func _is_valid_sample(shape: int, sample: Vector2, transpose: Vector2, cell_size_scaled: Vector2, cols: int, rows: int, grid: Array, points: Array, poisson_radius: float) -> bool:
	var cell := Vector2(int((transpose.x + sample.x) / cell_size_scaled.x), int((transpose.y + sample.y) / cell_size_scaled.y))
	var cell_start := Vector2(max(0, cell.x - 2), max(0, cell.y - 2))
	var cell_end := Vector2(min(cell.x + 2, cols - 1), min(cell.y + 2, rows - 1))

	for i in range(cell_start.x, cell_end.x + 1):
		for j in range(cell_start.y, cell_end.y + 1):
			var search_index: int = grid[i][j]
			if search_index != -1:
				var dist: float = points[search_index].distance_to(sample)
				if dist < poisson_radius:
					return false
	return true


static func _is_point_in_sample_region(sample: Vector2, shape: int) -> bool:
	if shape == ShapeType.POLYGON and Geometry2D.is_point_in_polygon(sample, shape_info[shape]["points"]):
			return true
	elif shape == ShapeType.CIRCLE and Geometry2D.is_point_in_circle(sample, shape_info[shape]["circle_position"], shape_info[shape]["circle_radius"]):
			return true
	else:
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

