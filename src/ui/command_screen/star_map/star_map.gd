@tool
extends Control

@export_group("Poisson Disc")
@export var circle_radius: float = 256:
	set(value):
		circle_radius = value
		redraw_points()
		generate_starlanes()
@export var poisson_radius: float = 50:
	set(value):
		poisson_radius = value
		redraw_points()
		generate_starlanes()
@export var retries: int = 30:
	set(value):
		retries = value
		redraw_points()
		generate_starlanes()

@export_group("Starlane Generation")
@export_range(0, 100, 1) var galactic_center_radius: float = 30:
	set(value):
		galactic_center_radius = value
		generate_starlanes()
@export_range(0, 100, 1) var galactic_center_connection_chance: float = 80:
	set(value):
		galactic_center_connection_chance = value
		generate_starlanes()
@export_range(0, 1, 0.01) var galactic_center_connection_jitter: float = 0.8:
	set(value):
		galactic_center_connection_jitter = value
		generate_starlanes()
@export_range(0, 100, 1) var tertiary_connection_chance: float = 30:
	set(value):
		tertiary_connection_chance = value
		generate_starlanes()
@export_range(0, 1, 0.01) var tertiary_connection_jitter: float = 0.5:
	set(value):
		tertiary_connection_jitter = value
		generate_starlanes()

@export_group("Negation Zone")
@export_range(0, 10000, 1) var negation_zone_radius: int = 256:
	set(value):
		negation_zone_radius = value

var points_to_draw: PackedVector2Array
var starmap_graph: Graph
var edges_to_draw = []
var adjacency_list = []
var negation_zone_center: Vector2 = Vector2.ZERO

enum ShapeType {CIRCLE, POLYGON}
static var shape_info: Dictionary


func _ready():
	redraw_points()
	generate_starlanes()


func _draw():
	# Starlanes
	if edges_to_draw:
		for edge in edges_to_draw:
			var negated_vert = []
			var negation_value = 0
			# 0 = not in negation zone
			# 1 = line crosses the negation range - clip it at the negation radius
			# 2 = line outside of negation range - don't draw
			for _vertex in edge:
				if not _vertex is Vector2:
					continue
				if not Geometry2D.is_point_in_circle(_vertex, negation_zone_center, negation_zone_radius):
					negation_value += 1
					negated_vert.append(_vertex)
			match negation_value:
				0:
					draw_line(edge[0], edge[1], Color.GOLD, 1.0)
				1:
					var _vert = negated_vert.pop_front()
					if _vert == edge[0]:
						var clamped_edge = (negation_zone_radius) * edge[0].normalized()
						draw_line(clamped_edge, edge[1], Color.RED, 1.0)
					elif _vert == edge[1]:
						var clamped_edge = (negation_zone_radius) * edge[1].normalized()
						draw_line(edge[0], clamped_edge, Color.RED, 1.0)
				_:
					continue
	# Stars
	if points_to_draw:
		for point in points_to_draw:
			if Geometry2D.is_point_in_circle(point, negation_zone_center, negation_zone_radius):
				draw_circle(point, 2, Color.WHITE)
	# Negation Zone edge
	draw_circle_donut_poly(
		negation_zone_center, negation_zone_radius, negation_zone_radius + 2, 
		0, 360, Color.ORANGE
	)
	# Negation Zone backfill
	draw_circle_donut_poly(
		negation_zone_center, negation_zone_radius, 500, 
		0, 360, Color(1, 0, 0, 0.5)
	)
	draw_circle(
		Vector2.ZERO, galactic_center_radius, Color(Color(0.941176, 1, 1, 0.4))
	)


func _process(_delta):
	queue_redraw()


func redraw_points() -> void:
	points_to_draw = generate_points_for_circle(Vector2.ZERO, circle_radius, poisson_radius, retries)


class Graph:
	var vertices
	var graph
	var mst
	
	func _init(vertices):
		self.vertices = vertices
		self.graph = []
		self.mst = []
	
	# Function to add an edge to graph 
	func add_edge(u, v, w): 
		self.graph.append([u, v, w]) 
	
	# Turn each point index into a world position
	func convert_to_world(edges, world_points):
		var result = []
		for i in range(edges.size() - 1):
			var _edge_world = [
				world_points[edges[i][0]],
				world_points[edges[i][1]],
				edges[i][2]
			]
			result.append(_edge_world)
			
		return result
  
	# A utility function to find set of an element i 
	# (truly uses path compression technique) 
	func find(parent, i): 
		if parent[i] != i: 
			# Reassignment of node's parent 
			# to root node as 
			# path compression requires 
			parent[i] = self.find(parent, parent[i]) 
		return parent[i] 
  
	# A function that does union of two sets of x and y 
	# (uses union by rank) 
	func union(parent, rank, x, y): 
		# Attach smaller rank tree under root of 
		# high rank tree (Union by Rank) 
		if rank[x] < rank[y]: 
			parent[x] = y 
		elif rank[x] > rank[y]: 
			parent[y] = x 
		# If ranks are same, then make one as root 
		# and increment its rank by one 
		else: 
			parent[y] = x 
			rank[x] += 1
	
	# The main function to construct MST 
	# using Kruskal's algorithm 
	func kruskal_mst(): 
		# This will store the resultant MST 
		var result = [] 
		# An index variable, used for sorted edges 
		var i = 0
		# An index variable, used for result[] 
		var e = 0
		# Sort all the edges in non-decreasing order of their weight 
		self.graph.sort_custom(func(a, b): return a[2] < b[2]) 
		var parent = [] 
		var rank = [] 
		# Create V subsets with single elements 
		for node in range(self.vertices.size()): 
			parent.append(node) 
			rank.append(0) 
		# Number of edges to be taken is less than to V-1 
		while e < self.vertices.size() - 1: 
			# Pick the smallest edge and increment 
			# the index for next iteration
			var edge = self.graph[i]
			var u = edge[0]
			var v = edge[1]
			var w = edge[2]
			i = i + 1
			var x = self.find(parent, u) 
			var y = self.find(parent, v) 
			# If including this edge doesn't 
			# cause cycle, then include it in result 
			# and increment the index of result 
			# for next edge 
			if x != y: 
				e = e + 1
				result.append([u, v, w]) 
				self.union(parent, rank, x, y) 
			# Else discard the edge 
		var minimumCost = 0
		for edge in result:
			var u = edge[0]
			var v = edge[1]
			var weight = edge[2]
			minimumCost += weight 
		
		return result


func _weight_toward_centre(a: Vector2, b: Vector2) -> float:
	var close_vertex
	var far_vertex
	if a.distance_to(Vector2.ZERO) < b.distance_to(Vector2.ZERO):
		close_vertex = a
		far_vertex = b
	else:
		close_vertex = b 
		far_vertex = a
	
	# Calculate how closely the edge vector points to the centre
	var edge_dir = far_vertex.direction_to(close_vertex)
	var dir_to_centre = close_vertex.direction_to(Vector2.ZERO)
	var dot = edge_dir.dot(dir_to_centre)
	
	var weight = remap(abs(dot), 0, 1, 10, 1)
	
	return weight


func _distance_to_centre(a: Vector2, b: Vector2) -> float:
	var close_vertex
	var far_vertex
	if a.distance_to(Vector2.ZERO) < b.distance_to(Vector2.ZERO):
		close_vertex = a
		far_vertex = b
	else:
		close_vertex = b 
		far_vertex = a
	return close_vertex.distance_to(Vector2.ZERO)


func _generate_tertiary_lanes(all_edges, mst_edges):
	randomize()
	var result = []
	var non_mst_edges = all_edges.filter(
		func(edge): return not edge in mst_edges
	)
	for edge in non_mst_edges:
		# Generate more tertiary connections the closer we are to the centre
		var dist = _distance_to_centre(edge[0], edge[1])
		if dist <= galactic_center_radius:
			dist = remap(dist, 0, galactic_center_radius, 0, galactic_center_connection_jitter)
			if randf() + dist < galactic_center_connection_chance / 100:
				result.append(edge)
		else:
			dist = remap(dist, 0, circle_radius, 0, tertiary_connection_jitter)
			if randf() + dist < tertiary_connection_chance / 100:
				result.append(edge)
	
	return result

func generate_starlanes() -> void:
	# Build Graph object to store edges and MST
	starmap_graph = Graph.new(points_to_draw)
	
	# Generate fully connected graph using delaunay triangulation
	var triangle_point_idxs = Geometry2D.triangulate_delaunay(points_to_draw)
	var triangles = []
	# Turn the list of point indexes into defined triangle clusters of point indexes
	for i in range(len(triangle_point_idxs) / 3):
		var _triangle = []
		# Each 3 consecutive points compose the vertices of one triangle
		for j in range(3):
			_triangle.append(triangle_point_idxs[(i * 3) + j])
		triangles.append(_triangle)
	# Calculate edges to draw
	edges_to_draw = []
	for _triangle in triangles:
		for i in range(3):
			var next_idx = null
			match i:
				2:
					next_idx = 0
				_:
					next_idx = i + 1
			var _weight = _weight_toward_centre(
				points_to_draw[_triangle[i]],
				points_to_draw[_triangle[next_idx]]
			)
			starmap_graph.add_edge(_triangle[i], _triangle[next_idx], _weight)
	#
	starmap_graph.mst = starmap_graph.kruskal_mst()
	var all_edges = starmap_graph.convert_to_world(starmap_graph.graph, points_to_draw)
	var mst_lanes = starmap_graph.convert_to_world(starmap_graph.mst, points_to_draw)
	var tertiary_lanes = _generate_tertiary_lanes(all_edges, mst_lanes)
	edges_to_draw = mst_lanes + tertiary_lanes


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

