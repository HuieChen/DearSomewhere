// Reversible pigment treatment, before the scene's existing daylight tint.
// Keep authored hue families and alpha; soften the character's isolated
// digital contrast so the painted figure sits inside the same paper atmosphere
// as the street behind it.
vec3 character_pigment(vec3 rgb) {
 float luminance=dot(rgb,vec3(.2126,.7152,.0722));
 vec3 pigment=mix(vec3(luminance),rgb,.80);
 pigment=(pigment-vec3(.5))*.91+vec3(.5);
 pigment=mix(pigment,vec3(.30,.27,.21),.08*(1.0-luminance));
 // A small warm paper wash reduces the cutout feeling without flattening
 // authored accents such as the courier's bag, eyes and hair.
 pigment=mix(pigment,vec3(.94,.94,.90),.06);
 pigment*=vec3(.985,.975,.945);
 return clamp(pigment,vec3(0.0),vec3(1.0));
}
