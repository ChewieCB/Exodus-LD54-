extends PPG_PlanetType

@onready var water = $Water
@onready var land = $Land
@onready var cloud = $Cloud

var color_vars1 = ["color1","color2","color3"]
var color_vars2 = ["col1","col2","col3", "col4"]
var color_vars3 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]

func set_pixels(amount):
	water.material.set_shader_parameter("pixels", amount)
	land.material.set_shader_parameter("pixels", amount)
	cloud.material.set_shader_parameter("pixels", amount)

	water.size = Vector2(amount, amount)
	land.size = Vector2(amount, amount)
	cloud.size = Vector2(amount, amount)

func set_light(pos):
	cloud.material.set_shader_parameter("light_origin", pos)
	water.material.set_shader_parameter("light_origin", pos)
	land.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	cloud.material.set_shader_parameter("seed", converted_seed)
	water.material.set_shader_parameter("seed", converted_seed)
	land.material.set_shader_parameter("seed", converted_seed)
	cloud.material.set_shader_parameter("cloud_cover", randf_range(0.35, 0.6))

func set_rotate(r):
	cloud.material.set_shader_parameter("rotation", r)
	water.material.set_shader_parameter("rotation", r)
	land.material.set_shader_parameter("rotation", r)

func update_time(t):
	cloud.material.set_shader_parameter("time", t * get_multiplier(cloud.material) * 0.01)
	water.material.set_shader_parameter("time", t * get_multiplier(water.material) * 0.02)
	land.material.set_shader_parameter("time", t * get_multiplier(land.material) * 0.02)

func set_custom_time(t):
	cloud.material.set_shader_parameter("time", t * get_multiplier(cloud.material))
	water.material.set_shader_parameter("time", t * get_multiplier(water.material))
	land.material.set_shader_parameter("time", t * get_multiplier(land.material))

func set_dither(d):
	water.material.set_shader_parameter("should_dither", d)

func get_dither():
	return water.material.get_shader_parameter("should_dither")



func get_colors():
	return (_get_colors_from_vars(water.material, color_vars1)
	+ _get_colors_from_vars(land.material, color_vars2)
	+ _get_colors_from_vars(cloud.material, color_vars3)
	)

func set_colors(colors):
	_set_colors_from_vars(water.material, color_vars1, colors.slice(0, 3, 1))
	_set_colors_from_vars(land.material, color_vars2, colors.slice(3, 7, 1))
	_set_colors_from_vars(cloud.material, color_vars3, colors.slice(7, 11, 1))

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(randi()%2+3, randf_range(0.7, 1.0), randf_range(0.45, 0.55))
	var land_colors = []
	var water_colors = []
	var cloud_colors = []
	for i in 4:
		var new_col = seed_colors[0].darkened(i/4.0)
		land_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))

	for i in 3:
		var new_col = seed_colors[1].darkened(i/5.0)
		water_colors.append(Color.from_hsv(new_col.h + (0.1 * (i/2.0)), new_col.s, new_col.v))

	for i in 4:
		var new_col = seed_colors[2].lightened((1.0 - (i/4.0)) * 0.8)
		cloud_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))

	set_colors(water_colors + land_colors + cloud_colors)
