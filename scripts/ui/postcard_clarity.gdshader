shader_type canvas_item;
render_mode unshaded;
uniform sampler2D card_source : filter_nearest, repeat_disable;
varying vec4 item_tint;
void vertex(){item_tint=COLOR;}
vec4 source_pixel(vec2 at,vec2 dimensions){
	if(any(lessThan(at,vec2(0.0))) || any(greaterThanEqual(at,dimensions)))return vec4(0.0);
	return textureLod(card_source,(at+.5)/dimensions,0.0);
}
// Reconstruct the original premultiplied pixels, not the transparent matte.
// Cubic sampling retains the authored colour boundaries when enlarged.
float cubic(float x) {
	x=abs(x);
	if(x<1.0)return 1.5*x*x*x-2.5*x*x+1.0;
	if(x<2.0)return -.5*x*x*x+2.5*x*x-4.0*x+2.0;
	return 0.0;
}
void fragment(){
	vec2 dimensions=vec2(textureSize(card_source,0));
	vec2 pixel=UV*dimensions-.5;
	vec2 base=floor(pixel);
	vec4 paint=vec4(0.0);
	float clean_alpha=0.0;
	for(int y=-1;y<=2;y++)for(int x=-1;x<=2;x++){
		vec2 offset=vec2(float(x),float(y));
		vec2 at=base+offset;
		// Transparent padding outside the layer prevents edge smearing.
		float weight=cubic(pixel.x-at.x)*cubic(pixel.y-at.y);
		vec4 original=source_pixel(at,dimensions);
		paint+=original*weight;
		float neighbours=source_pixel(at+vec2(1,0),dimensions).a+source_pixel(at-vec2(1,0),dimensions).a+source_pixel(at+vec2(0,1),dimensions).a+source_pixel(at-vec2(0,1),dimensions).a;
		clean_alpha+=(original.a*.5+neighbours*.125)*weight;
	}
	vec3 pigment=clamp(paint.rgb/max(paint.a,.001),vec3(0.0),vec3(1.0));
	// Remove the low-coverage fringe; keep about one output pixel of AA.
	float width=max(fwidth(clean_alpha)*.65,.025);
	float coverage=smoothstep(.48-width,.48+width,clean_alpha);
	COLOR=vec4(pigment,coverage)*item_tint;
}
