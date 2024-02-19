shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

void fragment() {
	if (texture(screen_texture, SCREEN_UV).r <= 0.0) {
		COLOR.rgb = vec3(135.0/255.0, 145.0/255.0, 136.0/255.0);
	} else {
		COLOR.rgb = vec3(0.0);
	}
}
