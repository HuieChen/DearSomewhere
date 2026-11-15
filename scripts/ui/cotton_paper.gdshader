shader_type canvas_item;
render_mode unshaded;
varying vec4 tint;
void vertex() { tint = COLOR; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i+vec2(1,0)), u.x), mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)),u.x),u.y);
}
void fragment() {
    vec2 p = FRAGCOORD.xy;
    float pulp = (noise(p/63.0)-0.5)*0.024 + (noise(p/17.0)-0.5)*0.018;
    float grain = (hash(p)-0.5)*0.022;
    float fibers = pow(noise(vec2(p.x/2.4+p.y/13.0,p.y/10.0)), 7.0)*0.045;
    vec3 paper = vec3(0.966,0.950,0.912) + pulp + grain - fibers*vec3(0.58,0.52,0.40);
    COLOR = vec4(paper,tint.a);
}
