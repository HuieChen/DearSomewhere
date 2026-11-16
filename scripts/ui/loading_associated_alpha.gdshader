shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

varying vec4 item_tint;
void vertex() {
    item_tint = COLOR;
}
void fragment() {
    vec4 source = texture(TEXTURE, UV);
    // Suppress decoder RGB in transparent pixels without changing the alpha
    // silhouette. Associated RGB and alpha must fade by the same factor.
    vec3 associated = clamp(source.rgb, vec3(0.0), vec3(source.a));
    COLOR = vec4(associated * item_tint.rgb * item_tint.a,
                 source.a * item_tint.a);
}
