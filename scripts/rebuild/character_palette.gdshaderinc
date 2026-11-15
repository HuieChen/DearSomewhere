// Reversible pigment treatment, before the scene's existing daylight tint.
// Keep authored hue families and alpha. The incoming tint is the same
// time-of-day light used by the street, so the character follows morning,
// sunset and night instead of sitting under one permanent grey wash.
vec3 character_pigment(vec3 rgb, vec3 scene_tint) {
 float luminance=dot(rgb,vec3(.2126,.7152,.0722));
 // Preserve the supplied painted hues; the former .85 mix made every
 // shadow drift toward grey before the scene light was applied.
 vec3 pigment=mix(vec3(luminance),rgb,.96);
 pigment=(pigment-vec3(.5))*1.015+vec3(.5);
 // Apply only the chroma of the current scene light here. The final
 // item_tint multiplication below still carries the full luminance change.
 float scene_luminance=max(dot(scene_tint,vec3(.2126,.7152,.0722)),.001);
 vec3 light_chroma=clamp(scene_tint/scene_luminance,vec3(.82),vec3(1.18));
 pigment*=mix(vec3(1.0),light_chroma,.32);
 // Lift the deepest night shadows a touch so a blue night does not collapse
 // into a flat charcoal silhouette.
 float low_light=1.0-smoothstep(.58,.92,scene_luminance);
 pigment+=vec3(.018,.014,.010)*low_light*.35;
 // Keep the paper integration nearly invisible; colour should belong to the
 // character first and the page atmosphere second.
 pigment=mix(pigment,vec3(.96,.95,.90),.008);
 pigment*=vec3(1.0,.995,.98);
 return clamp(pigment,vec3(0.0),vec3(1.0));
}
