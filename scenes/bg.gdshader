shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	uv.x += TIME * 0.05 + sin(TIME + uv.y * 5.0) * 0.05;
	uv.y += -TIME * 0.05;
	COLOR = texture(TEXTURE, uv) * 0.5;
	COLOR += texture(TEXTURE, UV + TIME * 0.02) * 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
