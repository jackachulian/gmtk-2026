shader_type canvas_item;
uniform float intensity: hint_range(-1.0, 1.0, 0.001) = 0.065;
uniform sampler2D ST : hint_screen_texture, filter_nearest;

void fragment() {
	float map = distance(SCREEN_UV, vec2(0.5));
	COLOR = texture(ST, vec2(
		SCREEN_UV.x - (map - 0.5) * intensity * (0.5 - SCREEN_UV.x),
		SCREEN_UV.y - (map - 0.5) * intensity * (0.5 - SCREEN_UV.y))
	);
}
