shader_type canvas_item;
render_mode unshaded;
#include "res://scripts/rebuild/character_palette.gdshaderinc"
varying vec4 item_tint;
uniform vec2 upper_shift = vec2(0.0);
uniform sampler2D next_frame : filter_linear;
uniform vec2 next_upper_shift = vec2(0.0);
uniform float pose_blend = 0.0;
void vertex() { item_tint = COLOR; }

// Filter the movie's native premultiplied colour and alpha together, then
// convert once for Godot's straight-alpha canvas blend. No contour erosion,
// colour key, or borrowed neighbour pigment: keep the supplied ink intact.
void fragment() {
	// Rigid upper-body registration removes the captured head-position jump.
	// The waist feathers this translation to zero; boots keep their exact UVs.
	vec2 at=UV;
	for(int i=0;i<2;i++)at=UV-upper_shift*(1.0-smoothstep(0.58,0.80,at.y));
	vec4 painted=texture(TEXTURE,at);
	// The movie is authored at six poses per second. Crossfade only the
	// registered upper body into the following pose; the planted lower body
	// keeps the current contact pixels, so the stride stays grounded while the
	// head and shoulders stop snapping at the source frame boundary.
	vec2 next_at=UV;
	for(int i=0;i<2;i++)next_at=UV-next_upper_shift*(1.0-smoothstep(0.58,0.80,next_at.y));
	vec4 following=texture(next_frame,next_at);
	float upper=smoothstep(0.80,0.56,UV.y);
	float blend=clamp(pose_blend,0.0,1.0)*upper;
	vec3 current_rgb=painted.rgb/max(painted.a,0.0001);
	vec3 next_rgb=following.rgb/max(following.a,0.0001);
	vec3 rgb=mix(current_rgb,next_rgb,blend);
	COLOR=vec4(character_pigment(rgb,item_tint.rgb),painted.a)*item_tint;
}
