shader_type canvas_item;

uniform vec4 play_field_rect;
uniform bool use_texture = false;

varying vec2 world_position;
varying vec4 vertex_color;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	vertex_color = COLOR;
}

void fragment() {
	if (world_position.x < play_field_rect.x || world_position.y < play_field_rect.y || world_position.x > play_field_rect.z || world_position.y > play_field_rect.w) {
		discard;
	}
	if (use_texture) {
		COLOR = vertex_color * texture(TEXTURE, vec2(UV.x, 1.0 - UV.y));
	} else {
		vec2 centered_uv = UV * 2.0 - vec2(1.0);
		if (dot(centered_uv, centered_uv) > 1.0) {
			discard;
		}
	}
}
