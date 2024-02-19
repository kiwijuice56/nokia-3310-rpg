shader_type canvas_item;

void fragment() {
	if (COLOR.r < 0.0) {
		COLOR.rgb = vec3(135.0/255.0, 145.0/255.0, 136.0/255.0);
	} else {
		COLOR.rgb = vec3(0.0);
	}
}
