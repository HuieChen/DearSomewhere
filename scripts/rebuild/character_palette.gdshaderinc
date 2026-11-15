// Reversible pigment treatment, before the scene's existing daylight tint.
// Keep authored hue families and alpha; soften the character's isolated
// digital contrast so the painted figure sits inside the same paper atmosphere
// as the street behind it.
vec3 character_pigment(vec3 rgb) {
 float luminance=dot(rgb,vec3(.2126,.7152,.0722));
 vec3 pigment=mix(vec3(luminance),rgb,.85);
 pigment=(pigment-vec3(.5))*.94+vec3(.5);
 pigment=mix(pigment,vec3(.30,.27,.21),.065*(1.0-luminance));
 // Keep a very small warm paper wash for integration without making the
 // character's painted accents look grey or chalky.
 pigment=mix(pigment,vec3(.96,.95,.90),.025);
 pigment*=vec3(.995,.985,.955);
 return clamp(pigment,vec3(0.0),vec3(1.0));
}
