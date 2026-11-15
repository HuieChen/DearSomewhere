shader_type canvas_item;
render_mode unshaded;

uniform float flow_time = 0.0;
uniform float fill_progress = 1.0;
varying vec4 item_modulate;
void vertex() { item_modulate = COLOR; }

// The source texture is the supplied loading-bar artwork. The shader only
// adds a restrained liquid motion to its blue water area; the frame, paper
// edge and lettering remain the authored pixels.
void fragment() {
	vec2 uv = UV;
	float bar_area = smoothstep(0.30, 0.36, uv.y) * (1.0 - smoothstep(0.66, 0.69, uv.y));
	vec2 ripple = vec2(
		sin(uv.y * 28.0 + flow_time * 2.2) * 0.006,
		sin(uv.x * 24.0 - flow_time * 2.0) * 0.008
	) * bar_area;
	vec4 sample_color = texture(TEXTURE, uv + ripple);
	float blue_water = smoothstep(0.035, 0.24, sample_color.b - sample_color.r) * bar_area * sample_color.a;
	// Reveal only the original blue water; frame and Loading lettering stay fixed.
	float front = mix(0.075,0.79,fill_progress) + sin(flow_time*2.0)*0.006;
	float filled = 1.0-smoothstep(front-0.012,front+0.012,uv.x);
	sample_color.rgb = mix(sample_color.rgb, vec3(0.73,0.87,0.97),blue_water*(1.0-filled)*0.92);
	float sheen_wave = sin(uv.x * 18.0 + flow_time * 1.45) * 0.5 + 0.5;
	float sheen = smoothstep(0.62, 0.96, sheen_wave) * blue_water * 0.055;
	sample_color.rgb += vec3(0.55, 0.78, 1.0) * sheen;
	COLOR = sample_color * item_modulate;
}
