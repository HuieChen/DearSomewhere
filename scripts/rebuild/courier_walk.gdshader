shader_type canvas_item;
render_mode unshaded;
#include "res://scripts/rebuild/character_palette.gdshaderinc"
varying vec4 item_tint;
uniform vec2 upper_shift = vec2(0.0);
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
	vec3 rgb=painted.rgb/max(painted.a,0.0001);
	COLOR=vec4(character_pigment(rgb,item_tint.rgb),painted.a)*item_tint;
}
