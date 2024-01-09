extends Node2D

@export_group("Poisson Disc")
@export var circle_radius: float = 256:
	set(value):
		circle_radius = value
		redraw_points()
		generate_starlanes()
@export var poisson_radius: float = 32:
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
#var black_hole_radius: float = 15
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
@export var is_negation_zone_active: bool = false:
	set = set_is_negation_zone_active
@export_range(0, 10000, 1) var negation_zone_radius: float = 256:
	set(value):
		# Cache previous value for lerping
		previous_negation_zone_radius = negation_zone_radius
		negation_zone_radius = value
		# Mapping for shader size
		if mapped_negation_radius:
			# Update negation zone shader params
			mapped_negation_radius = remap(
				negation_zone_radius, 
				0, initial_negation_zone_radius,
				0, 0.25
			)
@export_range(0, 5, 0.1) var NEGATION_ZONE_RATE: float = 3.5
@onready var initial_negation_zone_radius: float = negation_zone_radius
var previous_negation_zone_radius: float
# If we're within the debuff distance to the negation zone, 
# we lose morale scaled by how close we are.
@export_range(0, 100, 1) var morale_debuff_min_distance: int = 0
@export_range(0, 100, 1) var morale_debuff_max_distance: int = 75
@export_range(-20.0, -0.1, 0.1) var morale_debuff_min: float = -0.5
@export_range(-20.0, -0.1, 0.1) var morale_debuff_max: float = -10.0
# If we're at least the buff distance away from the negation zone, 
# we gain morale scaled by how far we are.
@export_range(100, 1000, 1) var morale_buff_min_distance: int = 100
@export_range(100, 1000, 1) var morale_buff_max_distance: int = 400
@export_range(0.1, 20.0, 0.1) var morale_buff_min: float = 0.5
@export_range(0.1, 20.0, 0.1) var morale_buff_max: float = 4.0


var points_to_draw: PackedVector2Array
var edges_to_draw = []
#
var active_stars: Array = []
var starmap_graph: Graph
#
var available_spawn_lanes = []
var previous_star_lanes = []

var negation_zone_center: Vector2 = Vector2.ZERO
@onready var adjusted_center = negation_zone_center + get_global_transform().origin

var previous_star: StarNode
var next_star: StarNode
var queued_stars: Array = []
var chevrons_instance: Line2D
var queued_chevrons: Array = []

var start_star: StarNode
var goal_star: StarNode
var goal_point: Vector2

# TODO - refactor this to be non-hardcoded
var tutorial_star: StarNode

const SHIP_MOVE_RATE: float = 1.0 # Default is 1.0
var is_ship_travelling: bool = false

var NEGATION_FIELD_SHRINK_RATE: float = 1.0
@onready var mapped_negation_radius: float = 0.25

enum ShapeType {CIRCLE, POLYGON}
static var shape_info: Dictionary

@onready var camera = $Camera2D

@onready var stars_parent = $Stars
@onready var star_node = preload("res://src/ui/star_map/star/StarNode.tscn")
@onready var starlanes_parent = $Starlanes
@onready var starlane_scene = load("res://src/ui/star_map/starlane/Starlane.tscn")
@onready var starlane_chevrons_scene = load("res://src/ui/star_map/starlane/StarlaneChevrons.tscn")
@onready var chevrons_parent = $Chevrons

@onready var negation_zone_shader = $NegationZone
@onready var negation_zone_edge_shader = $NegationZoneEdge

@onready var current_ship_position: Vector2 = $ShipTracker.global_position

var viewport_has_focus: bool = false
var target_zoom: float = 1.0
var star_shaders_visible = 0:
	set(value):
		star_shaders_visible = value


func _ready():
	redraw_points()
	generate_starlanes()
	# TODO - figure out why we need that extra 32 pixels on the sizes 
	$GalacticCenter.size = Vector2(galactic_center_radius * 2 + 32, galactic_center_radius * 2 + 32)
	$GalacticCenter.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	#
	$BlackHole.size = Vector2(galactic_center_radius/2, galactic_center_radius/2)
	$BlackHole.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	#
	negation_zone_shader.size = Vector2(negation_zone_radius * 4, negation_zone_radius * 4)
	negation_zone_shader.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	negation_zone_shader.material.set_shader_parameter("circle_size", 0.25)
	negation_zone_edge_shader.size = Vector2(negation_zone_radius * 4, negation_zone_radius * 4)
	negation_zone_edge_shader.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	negation_zone_edge_shader.material.set_shader_parameter("radius", 0.5)
	EventManager.trigger_negation_zone.connect(set_is_negation_zone_active)
	
	# Add star shaders
	active_stars = generate_stars(active_stars)
	
	# Pick an outer star and place the ship tracker there
	var outer_stars = get_outer_stars(active_stars)
	start_star = outer_stars[randi_range(0, outer_stars.size() - 1)]
	
	# Pick a star near the center of the galaxy and set the goal there
	var inner_stars: Array = get_inner_stars(active_stars)
	inner_stars.sort_custom(
		func(a, b):
			return a.global_position.distance_to(start_star.global_position) \
			> b.global_position.distance_to(start_star.global_position)
	)
	goal_star = inner_stars.front()
	goal_star.is_goal = true
	
	# DEBUG
	print("Start point distance = ", negation_zone_radius - start_star.global_position.distance_to(adjusted_center))
	previous_star = active_stars.filter(
		func(star): return star == start_star
	).front()
	# Move ship to start point
	$ShipTracker.global_position = start_star.global_position
	# Move camera
	camera.ship_node = $ShipTracker
	camera.current_target = $ShipTracker
	
	EventManager.tutorial_neighbor_star_event.connect(set_tutorial_distress_signal)
	EventManager.end_tutorial_star_event.connect(cancel_tutorial_distress_signal)
	
	# Connect negation zone radius to tick
	TickManager.tick.connect(_on_tick)


func _draw():
	# Stars
	if points_to_draw and Engine.is_editor_hint():
		for point in points_to_draw:
			if Geometry2D.is_point_in_circle(point, negation_zone_center, negation_zone_radius):
				draw_circle(point, 2, Color.WHITE)
	# Negation Zone edge
	draw_circle_donut_poly(
		negation_zone_center, negation_zone_radius, negation_zone_radius + 4, 
		0, 360, Color(1, 0.647059, 0, 0.5)
	)


func _process(_delta):
	queue_redraw()


func _physics_process(delta):
	# If we have a destination, move towards it
	if is_ship_travelling:
		if next_star:
			var ship_speed_timescale = TickManager.get_timescale_modifier()
			# TODO - get lerp working for this so we can ease it
			$ShipTracker.global_position += \
				(next_star.global_position - $ShipTracker.global_position).normalized() * \
				SHIP_MOVE_RATE * ship_speed_timescale * delta
			
			$ShipTracker.global_rotation = lerp_angle(
				$ShipTracker.global_rotation, 
				$ShipTracker.global_rotation + $ShipTracker.get_angle_to(next_star.global_position), 
				delta * 2
			)
			
			# Update the chevrons to move with the ship
			if queued_chevrons:
				queued_chevrons.front().points[0] = _screen_to_viewport($ShipTracker.global_position)
		
			# When the ship reaches a star
			# Tried using is_equal_approx() for this but it needs a slightly wider margin of error
			if $ShipTracker.global_position.distance_to(next_star.global_position) < 1:
				var is_goal_star = next_star.global_position == goal_point
				EventManager.reached_a_star(next_star, is_goal_star)

				# Update relative stars
				previous_star = next_star
				next_star = null
				queued_stars.pop_front()
				
				# Remove the active chevrons
				if queued_chevrons:
					queued_chevrons.pop_front().queue_free()
				
				# Keep moving to next star if there's a queue
				if queued_stars:
					next_star = queued_stars.front()
					is_ship_travelling = true
				else:
					is_ship_travelling = false


func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if is_ship_travelling:
			# If the ship is mid-transit, remove the target and allow the 
			# player to turn around
			next_star = null
			previous_star = null
			queued_stars = []
			is_ship_travelling = false
			clear_chevrons()


func _viewport_to_screen(_position: Vector2) -> Vector2:
	return _position + get_global_transform().origin


func _screen_to_viewport(_position: Vector2) -> Vector2:
	return _position - get_global_transform().origin


func add_star_to_travel_queue(star: StarNode, start_point: Vector2 = $ShipTracker.global_position):
	if queued_stars:
		var last_star_in_queue = queued_stars[-1]
		if is_star_connected(star, last_star_in_queue):
			queued_stars.append(star)
			_update_queued_travel_path(
				_screen_to_viewport(queued_stars[-2].global_position), 
				_screen_to_viewport(queued_stars[-1].global_position)
			)
	else:
		var current_ship_position = _screen_to_viewport($ShipTracker.global_position)
		var connected_lanes = get_connected_starlanes(current_ship_position)
		for _lane in connected_lanes:
			for _point in _lane.slice(0, 2):
				var test0 = _screen_to_viewport(star.global_position)
				if _screen_to_viewport(star.global_position).is_equal_approx(_point):
					queued_stars.append(star)
					_update_queued_travel_path(
						start_point, 
						_screen_to_viewport(queued_stars[-1].global_position)
					)
					return
			# Fallback - are we in the middle of a starlane?
			if Geometry2D.get_closest_point_to_segment(
				start_point,
				_lane[0],
				_lane[1]
			).distance_to(start_point) < 1:
				# We can only travel to either end of the active starlane
				if _screen_to_viewport(star.global_position) in _lane.slice(0, 2):
					queued_stars.append(star)
					_update_queued_travel_path(
						start_point, 
						_screen_to_viewport(queued_stars[-1].global_position)
					)
					return


func _update_queued_travel_path(start_position: Vector2, end_position: Vector2):
	var _chevron_instance = starlane_chevrons_scene.instantiate()
	_chevron_instance.points = [start_position, end_position]
	chevrons_parent.add_child(_chevron_instance)
	queued_chevrons.append(_chevron_instance)
	
	# If this is the first star in the queue, set it as the next star
	if not next_star:
		next_star = queued_stars.front()
		is_ship_travelling = true


func is_star_connected(destination_star: StarNode, starting_star: StarNode) -> bool:
	if destination_star == starting_star:
		return false
	
	var connected_lanes = get_connected_starlanes(
		_screen_to_viewport(starting_star.global_position)
	)
	for _lane in connected_lanes:
		for _point in _lane.slice(0, 2):
			if _screen_to_viewport(destination_star.global_position).is_equal_approx(_point):
				return true
	
	return false


func get_star_connected_neighbors(star: StarNode) -> Array:
	var neighbors = []
	var _connected_lanes = get_connected_starlanes(_screen_to_viewport(star.global_position))
	for lane in _connected_lanes:
		var valid_point = lane.filter(
			func(item):
				return item is Vector2 \
				and not item.is_equal_approx(star.position)
		)[0]
		var neighbor_star = active_stars.filter(
			func(star):
				return _screen_to_viewport(star.global_position).is_equal_approx(valid_point)
		)
		neighbors.append(neighbor_star[0])
	return neighbors
	


func select_star_to_travel_to(star: StarNode):
	if not is_ship_travelling:
		var current_ship_position = _screen_to_viewport($ShipTracker.global_position)
		var star_position = _screen_to_viewport(star.global_position)
		
		# Override any existing queue
		queued_stars = []
		clear_chevrons()
		# Don't travel to a star if we're already at it
		if star_position == current_ship_position:
			return
		
		# Get available lanes
		var connected_lanes = get_connected_starlanes(current_ship_position)
		for _lane in connected_lanes:
			for _point in _lane.slice(0, 2):
				if star_position.is_equal_approx(_point):
					add_star_to_travel_queue(star, current_ship_position)
					# If this is the first star in the queue, set it as the next star
					if not next_star:
						next_star = queued_stars.front()
						is_ship_travelling = true
					return
			
			# Fallback - are we in the middle of a starlane?
			if Geometry2D.get_closest_point_to_segment(
				current_ship_position,
				_lane[0],
				_lane[1]
			).distance_to(current_ship_position) < 1:
				# We can only travel to either end of the active starlane
				if star.global_position in _lane.slice(0, 2):
					add_star_to_travel_queue(star, current_ship_position)
					# If this is the first star in the queue, set it as the next star
					if not next_star:
						next_star = queued_stars.front()
						is_ship_travelling = true
					return


func get_connected_starlanes(point: Vector2) -> Array:
	var connected_lanes = edges_to_draw.duplicate()
	# Filter out edges that don't connect to the start point
	connected_lanes = connected_lanes.filter(
		func(lane): 
			return lane[0].is_equal_approx(point) or \
			lane[1].is_equal_approx(point)
	)
	# If we're in the middle of a starlane, find the lane we're on
	if connected_lanes == []:
		connected_lanes = edges_to_draw.duplicate()
		connected_lanes = connected_lanes.filter(
			func(lane):
				return Geometry2D.get_closest_point_to_segment(
					point,
					lane[0],
					lane[1]
				).distance_to(point) < 5
		)
	
	return connected_lanes


func redraw_points() -> void:
	var valid_points = generate_points_for_circle(Vector2.ZERO, circle_radius, poisson_radius, retries)
	# Remove any points that would cross the black hole at the center
	points_to_draw = Array(valid_points).filter(
		func(point): 
			return not Geometry2D.is_point_in_circle(
				point, Vector2.ZERO, galactic_center_radius / 2
			)
	)

# <-------- v DIJKSTRA GRAPH CLASS - MOVE OUT INTO UTILS v -------->

class Graph:
	var vertices
	var graph
	var mst
	
	func _init(p_vertices):
		self.vertices = p_vertices
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
			# Workaround since we messed with the edge generation to avoid
			# the black hole.
			if i > graph.size() - 1:
				break
			# Pick the smallest edge and increment 
			# the index for next iteration
			var edge = self.graph[i]
			var u = edge[0]
			var v = edge[1]
			var w = edge[2]
			i += 1
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
	
	func dijsktra(source: int, n: int):
		# Function to perform Dijkstra's algorithm on a given graph starting 
		# from a given source vertex.
		#
		# Source is the vertex index for the start point
		# Array of adjacency lists
		var adjacency = Array()
		adjacency.resize(self.vertices.size())
		adjacency.fill([])
		var distances = []
		for i in range(n):
			distances[i] = INF
		
		# Initialize a boolean array to track visited vertices
		var vis = Array()
		vis.resize(n)
		vis.fill(false)
		
		# Set the distance to the source vertex to 0 and add it to a set of vertices to be processed
		var dist = 0
		var set = []
		set.append([0, source])
		
		# Loop until there are no more vertices to process
		while (set.size() > 0):
			# Get the vertex with the smallest distance from the set
			var p = set.pop_front()

			# If the vertex has already been visited, skip it
			var vert_index = p[0]
			var weight = p[1]

			if vis.has(vert_index):
				continue
			
			vis[vert_index] = true
			
			# Loop through the adjacency list of the current vertex
			for i in range(adjacency[vert_index].size()):
				var neigbor_index = adjacency[vert_index][i][0] # Neighbor vertex index
				var w = adjacency[vert_index][i][1] # Weight of the edge connecting the current vertex and its neighbor
				
				# If the distance to the neighbor vertex can be improved by going through the current vertex,
				# update its distance and add it to the set of vertices to be processed
				if (distances[vert_index] + w < distances[neigbor_index]):
					distances[neigbor_index] = distances[vert_index] + w
					set.append([distances[neigbor_index], neigbor_index])

# <-------- ^ DIJKSTRA GRAPH CLASS - MOVE OUT INTO UTILS ^ -------->

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
			# Don't generate lanes that pass through the black hole center
			if Geometry2D.segment_intersects_circle(
				points_to_draw[_triangle[i]], points_to_draw[_triangle[next_idx]], 
				Vector2.ZERO, galactic_center_radius / 2
			) != -1:
				continue
			starmap_graph.add_edge(_triangle[i], _triangle[next_idx], _weight)
	#
	starmap_graph.mst = starmap_graph.kruskal_mst()
	var all_edges = starmap_graph.convert_to_world(starmap_graph.graph, points_to_draw)
	var mst_lanes = starmap_graph.convert_to_world(starmap_graph.mst, points_to_draw)
	var tertiary_lanes = _generate_tertiary_lanes(all_edges, mst_lanes)
	edges_to_draw = mst_lanes + tertiary_lanes
	
	if starlane_scene:
		for edge in edges_to_draw:
			var negated_vert = []
			var negation_value = 0
			# 0 = not in negation zone
			# 1 = line crosses the negation range - clip it at the negation radius
			# 2 = line outside of negation range - don't draw
			for _vertex in edge.slice(0, 2):
				if not _vertex is Vector2:
					continue
				if not Geometry2D.is_point_in_circle(_vertex, negation_zone_center, negation_zone_radius):
					negation_value += 1
					negated_vert.append(_vertex)
			var starlane_instance = starlane_scene.instantiate()
			match negation_value:
				0:
					starlane_instance.points = [edge[0], edge[1]]
#					starlane_instance.material.set_shader_parameter("color", "#6effffb2")
#					starlane_instance.material.set_shader_parameter("outline_color", "#6effffb2")
				1:
					var _vert = negated_vert.pop_front()
					if _vert == edge[0]:
						var clamped_edge = (negation_zone_radius) * edge[0].normalized()
						starlane_instance.points = [clamped_edge, edge[1]]
#						starlane_instance.material.set_shader_parameter("color", "#ff8c7347")
#						starlane_instance.material.set_shader_parameter("outline_color", "#ff3b3ba0")
					elif _vert == edge[1]:
						var clamped_edge = (negation_zone_radius) * edge[1].normalized()
						starlane_instance.points = [edge[0], clamped_edge]
#						starlane_instance.material.set_shader_parameter("color", "#ff8c7347")
#						starlane_instance.material.set_shader_parameter("outline_color", "#ff3b3ba0")
				_:
					continue
			
			starlanes_parent.add_child(starlane_instance)


func generate_stars(stars_array: Array) -> Array:
	# Remove any pre-existing stars before we regenerate the map
	for _star in stars_array:
		_star.queue_free()
		stars_array.erase(_star)
	
	var star_node = load("res://src/ui/star_map/star/StarNode.tscn")
	for _point in points_to_draw:
		if Geometry2D.is_point_in_circle(_point, negation_zone_center, negation_zone_radius):
			var star_instance = star_node.instantiate()
			#
			star_instance.star_selected.connect(select_star_to_travel_to)
			star_instance.queue_star_selected.connect(add_star_to_travel_queue)
			star_instance.global_position = _point
			stars_parent.add_child(star_instance)
	return stars_parent.get_children()


func get_outer_stars(stars, min_distance=64, max_distance=128) -> Array:
	# We need to offset the center point here based on the origin of this scene
	# for when we run it as a SubViewport within the UI
	var outer_stars = Array(stars).filter(
		func(star): 
			var _star_distance = star.global_position.distance_to(adjusted_center)
			var _distance_to_negation_zone = negation_zone_radius + 1 - _star_distance
			return _distance_to_negation_zone > min_distance and \
			_distance_to_negation_zone < max_distance 
	)
	
	return outer_stars


func get_inner_stars(stars) -> Array:
	var inner_stars = Array(stars).filter(
		func(star): 
			return star.global_position.distance_to(adjusted_center) < galactic_center_radius - 24
	)
	
	return inner_stars

# <-------- v POISSON DISTRIBUTION METHODS - MOVE OUT INTO UTILS v -------->

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
	elif shape == ShapeType.CIRCLE and Geometry2D.is_point_in_circle(
		sample, 
		shape_info[shape]["circle_position"], 
		shape_info[shape]["circle_radius"]
	):
		return true
	else:
		return false

# <-------- ^ POISSON DISTRIBUTION METHODS - MOVE OUT INTO UTILS ^ -------->

# <-------- v DRAWING METHODS - MOVE OUT INTO UTILS v -------->

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)


func draw_circle_donut_poly(center, inner_radius, outer_radius, angle_from, angle_to, color):  
	var nb_points = 64 
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

# <-------- ^ DRAWING METHODS - MOVE OUT INTO UTILS ^ -------->


func clear_chevrons(start_idx: int = 0, end_idx: int = 0x7FFFFFFF):
	var chevrons_to_clear = queued_chevrons.slice(start_idx, end_idx)
	for _chevron in chevrons_to_clear:
		_chevron.queue_free()
		if _chevron in queued_chevrons:
			queued_chevrons.erase(_chevron)


func clear_negated_stars():
	# Find any stars that are inside the negation zone
	var negated_stars = Array(active_stars).filter(
		func(star):
			return star.global_position.distance_to(adjusted_center) >= negation_zone_radius - 1
	)
	for _star in negated_stars:
		# Cancel travel to the next star if it gets negated
		if _star == next_star:
			next_star = null
		# Clear the star and chevron queues from the removed star onward
		var star_idx = queued_stars.find(_star)
		if star_idx != -1:
			# Cut off the queues at the negated star index
			if star_idx == 0:
				clear_chevrons()
				queued_stars = []
			else:
				clear_chevrons(star_idx)
				queued_stars = queued_stars.slice(0, star_idx)
		# Remove the star as it is negated
		active_stars.erase(_star)
		_star.queue_free()


func handle_negated_starlanes():
	# Updated edge case starlanes
	var starlanes_in_negation_zone = starlanes_parent.get_children().filter(
		func(lane):
			var points = lane.points
			return points[0].distance_to(negation_zone_center) >= negation_zone_radius \
			or points[1].distance_to(negation_zone_center) >= negation_zone_radius
	)
	# Find which vertex is cut off by the negation zone
	for _lane in starlanes_in_negation_zone:
		var negated_vertex
		var safe_vertex
		if _lane.points[0].distance_to(negation_zone_center) >= negation_zone_radius:
			negated_vertex = 0
			safe_vertex = 1
		elif _lane.points[1].distance_to(negation_zone_center) >= negation_zone_radius:
			negated_vertex = 1
			safe_vertex = 0
		else:
			return
		
		# FIXME - this isn't quite cutting off at the negation zone for some reason.
		#
		# Update the point in the negation zone to point in the same direction,
		# but cut off at the current edge of the negation zone
		var intersection_ratio: float = Geometry2D.segment_intersects_circle(
			_lane.points[safe_vertex],
			_lane.points[negated_vertex],
			negation_zone_center,
			negation_zone_radius
		)
		var lane_vector = (
			_lane.points[negated_vertex] - _lane.points[safe_vertex]
		)
		var intersection_offset = lane_vector.normalized() * lane_vector.length() * intersection_ratio
		var intersection_point = _lane.points[safe_vertex] + intersection_offset
		
		_lane.points[negated_vertex] = intersection_point
		
		if _lane.cached_original_points[0].distance_to(negation_zone_center) >= negation_zone_radius \
		and _lane.cached_original_points[1].distance_to(negation_zone_center) >= negation_zone_radius:
			_lane.queue_free()
			starlanes_in_negation_zone.erase(_lane)


func set_tutorial_distress_signal() -> StarNode:
	var neighbors = get_star_connected_neighbors(start_star)
	var distress_star = neighbors.front()
	tutorial_star = distress_star
	distress_star.connected_event = EventManager.tutorial_events[7]
	
	camera.focus_on_node(distress_star, -1.0)
	await EventManager.dialogic_signal
	camera.release_focus()
	
	return distress_star


func cancel_tutorial_distress_signal() -> void:
	camera.release_focus()
	if tutorial_star:
		tutorial_star.has_signal = false
		tutorial_star = null


func _on_tick():
	if is_negation_zone_active:
		negation_zone_radius -= NEGATION_ZONE_RATE
		# Update negation radius shader
		negation_zone_shader.material.set_shader_parameter("circle_size", mapped_negation_radius)
		negation_zone_edge_shader.material.set_shader_parameter("radius", mapped_negation_radius * 2)
		# Update starmap
		clear_negated_stars()
		handle_negated_starlanes()
	#
	var ship_distance = $ShipTracker.global_position.distance_to(adjusted_center)
	var distance_to_negation_zone = negation_zone_radius + 1 - ship_distance
	# TODO - parameterize the negation_zone reduction
	var ticks_until_negation = floor((distance_to_negation_zone) / NEGATION_ZONE_RATE)
	EventManager.emit_signal("proximity_alert", ticks_until_negation)
	# Decrease morale when we're near the negation zone, 
	# and slightly increase morale when we're far away.
	#
	# Check if negation_zone envioronmental MoraleEffect already exists in queue
	var _negation_zone_effect = ResourceManager.morale_effect_queue.filter(
		func(effect):
			return effect.type == MoraleEffect.TYPES.EnvironmentalMoraleEffect \
			and effect._name.begins_with("Negation zone proximity")
	).pop_front()
	var current_morale_buff: int
	if distance_to_negation_zone <= morale_debuff_max_distance:
		current_morale_buff = remap(
			distance_to_negation_zone, 
			morale_debuff_max_distance, 
			morale_debuff_min_distance, 
			morale_debuff_min, 
			morale_debuff_max
		)
	elif distance_to_negation_zone >= morale_buff_min_distance:
		current_morale_buff = remap(
			distance_to_negation_zone, 
			morale_buff_min_distance, 
			morale_buff_max_distance, 
			morale_buff_min, 
			morale_buff_max
		)
	if _negation_zone_effect:
		if current_morale_buff != 0:
			_negation_zone_effect._name = "Negation zone proximity [%su]" % [round(distance_to_negation_zone)]
			_negation_zone_effect.morale_modifier_value = current_morale_buff
		else:
			ResourceManager.remove_morale_effect(_negation_zone_effect)
	else:
		if current_morale_buff != 0:
			ResourceManager.add_morale_effect(
				"Negation zone proximity [%s]u" % [round(distance_to_negation_zone)],
				 current_morale_buff, 
				-1, 
				MoraleEffect.TYPES.EnvironmentalMoraleEffect
			)
	# TODO - make negation zone shader draw OVER ship sprite
	#
	# Check if player is fully in negation zone, game over if they are
	if $ShipTracker.global_position.distance_to(adjusted_center) >= negation_zone_radius + 1:
		EventManager.emit_signal("negation_zone")


func set_is_negation_zone_active(value: bool):
	is_negation_zone_active = value


# FIXME - I don't think the following methods are connected to anything
# anymore, check and remove them.

func _on_viewport_mouse_entered():
	viewport_has_focus = true


func _on_viewport_mouse_exited():
	viewport_has_focus = false
	get_parent().gui_release_focus()
