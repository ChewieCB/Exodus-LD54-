shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0); 
uniform float speed = 1.0;

void fragment() {
	vec2 moving_uv = vec2(UV.x - TIME * speed, UV.y);
	vec4 input_texture = texture(TEXTURE, moving_uv);
	COLOR = input_texture * color;
}
