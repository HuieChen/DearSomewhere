shader_type canvas_item;
render_mode unshaded;
#include "res://scripts/rebuild/character_palette.gdshaderinc"
varying vec4 item_tint;
uniform vec2 upper_shift = vec2(0.0);
uniform vec4 boot_shift=vec4(0.0);
uniform bool animate_boots=false;
uniform sampler2D boot_regions : filter_linear_mipmap, repeat_disable;
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
float boot_mask(vec4 c,vec2 uv,bool light_boot) {
	vec2 mask=texture(boot_regions,uv).rg;
	return light_boot?mask.g:mask.r;
}
vec4 moving_boot(sampler2D source,vec2 uv,vec2 displacement,vec2 probe,bool light_boot) {
	vec2 at=uv;
	for(int i=0;i<3;i++)at=uv-displacement*smoothstep(0.755,0.96,at.y);
	vec4 painted=clean_sample(source,at,probe);
	return painted*boot_mask(painted,at,light_boot);
}
void fragment() {
	vec2 probe=max(TEXTURE_PIXEL_SIZE*2.0,fwidth(UV)*0.75);
	// Rigid upper-body registration removes the captured head-position jump.
	// The waist feathers upper registration to zero before boot articulation.
	vec2 at=UV;
	for(int i=0;i<2;i++)at=UV-upper_shift*(1.0-smoothstep(0.58,0.80,at.y));
	vec4 painted=clean_sample(TEXTURE,at,probe);
	if(animate_boots){
		float old_boot=max(boot_mask(painted,at,false),boot_mask(painted,at,true));
		painted*=1.0-clamp(old_boot,0.0,1.0);
		vec4 dark=moving_boot(TEXTURE,UV,boot_shift.xy,probe,false);
		vec4 light=moving_boot(TEXTURE,UV,boot_shift.zw,probe,true);
		vec4 legs=light+dark*(1.0-light.a);
		painted=painted+legs*(1.0-painted.a);
	}
	vec3 rgb=painted.rgb/max(painted.a,0.0001);
	COLOR=vec4(character_pigment(rgb,item_tint.rgb),painted.a)*item_tint;
}
