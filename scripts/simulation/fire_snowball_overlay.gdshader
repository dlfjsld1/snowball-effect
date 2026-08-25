shader_type canvas_item;

uniform vec4 play_field_rect;

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (world_position.x < play_field_rect.x || world_position.y < play_field_rect.y || world_position.x > play_field_rect.z || world_position.y > play_field_rect.w) {
		discard;
	}

	vec4 flame = texture(TEXTURE, UV);
	if (flame.a < 0.05) {
		discard;
	}
	COLOR *= flame;
}
