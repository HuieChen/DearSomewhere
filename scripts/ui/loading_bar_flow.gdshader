shader_type canvas_item;
render_mode unshaded;

uniform float flow_time = 0.0;
varying vec4 item_modulate;
void vertex() { item_modulate = COLOR; }

// The source texture is the supplied loading-bar artwork. The shader only
// adds a restrained liquid motion to its blue water area; the frame, paper
// edge and lettering remain the authored pixels.
void fragment() {
	vec2 uv = UV;
	float bar_area = smoothstep(0.30, 0.36, uv.y) * (1.0 - smoothstep(0.69, 0.75, uv.y));
	vec2 ripple = vec2(
		sin(uv.y * 34.0 + flow_time * 2.4) * 0.0028,
		sin(uv.x * 26.0 - flow_time * 2.0) * 0.0016
	) * bar_area;
	vec4 sample_color = texture(TEXTURE, uv + ripple);
	float blue_water = smoothstep(0.035, 0.24, sample_color.b - sample_color.r * 0.78) * bar_area * sample_color.a;
	float sheen_wave = sin(uv.x * 18.0 + flow_time * 1.45) * 0.5 + 0.5;
	float sheen = smoothstep(0.62, 0.96, sheen_wave) * blue_water * 0.055;
	sample_color.rgb += vec3(0.55, 0.78, 1.0) * sheen;
	COLOR = sample_color * item_modulate;
}
