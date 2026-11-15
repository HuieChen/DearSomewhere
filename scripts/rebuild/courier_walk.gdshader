shader_type canvas_item;
render_mode unshaded;
#include "res://scripts/rebuild/character_palette.gdshaderinc"
varying vec4 item_tint;
void vertex() { item_tint = COLOR; }

// Premultiplied textures keep transparent black out of the mipmap colour.
// Only the partially covered contour borrows pigment from the covered side;
// opaque eyebrows, boots and painted shadows retain their authored colours.
vec4 clean_sample(sampler2D source, vec2 uv, vec2 probe) {
	vec4 c = texture(source,uv);
	vec4 inside = c;
	for (int i=0; i<8; i++) {
		float angle=float(i)*0.785398163;
		vec4 neighbour=texture(source,uv+vec2(cos(angle),sin(angle))*probe);
		if (neighbour.a>inside.a) { inside=neighbour; }
	}
	vec3 rgb=c.rgb/max(c.a,0.0001);
	vec3 pigment=inside.rgb/max(inside.a,0.0001);
	float edge=(1.0-smoothstep(0.70,0.995,c.a))*smoothstep(0.03,0.25,inside.a-c.a);
	rgb=mix(rgb,pigment,edge);
	return vec4(rgb*c.a,c.a);
}
void fragment() {
	vec2 probe=max(TEXTURE_PIXEL_SIZE*2.0,fwidth(UV)*0.75);
	vec4 painted=clean_sample(TEXTURE,UV,probe);
	vec3 rgb=painted.rgb/max(painted.a,0.0001);
	COLOR=vec4(character_pigment(rgb,item_tint.rgb),painted.a)*item_tint;
}
