shader_type canvas_item;
render_mode unshaded;
uniform vec4 rim_color : source_color = vec4(0.91,0.49,0.20,1.0);
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 vec4 base=texture(TEXTURE,UV);
 vec2 pixel=fwidth(UV);
 vec2 p=pixel*0.65;
 float a=(texture(TEXTURE,UV).a*4.0+texture(TEXTURE,UV+p*vec2(1,0)).a+texture(TEXTURE,UV-p*vec2(1,0)).a+texture(TEXTURE,UV+p*vec2(0,1)).a+texture(TEXTURE,UV-p*vec2(0,1)).a)/8.0;
 float inner=a;
 for(int i=0;i<16;i++){
  float angle=float(i)*6.2831853/16.0;
  vec2 sample_uv=UV+vec2(cos(angle),sin(angle))*pixel*2.0;
  float ring=(texture(TEXTURE,sample_uv).a*4.0+texture(TEXTURE,sample_uv+p*vec2(1,0)).a+texture(TEXTURE,sample_uv-p*vec2(1,0)).a+texture(TEXTURE,sample_uv+p*vec2(0,1)).a+texture(TEXTURE,sample_uv-p*vec2(0,1)).a)/8.0;
  inner=min(inner,ring);
 }
 float rim=clamp((a-inner)/max(a,0.001),0.0,1.0);
 COLOR=vec4(mix(vec3(0.945,0.925,0.89),rim_color.rgb,rim),a)*tint;
}
