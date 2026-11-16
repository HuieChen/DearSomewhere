extends Label
## A nearby name belongs to its original actor; it never intercepts world input.
var courier:Control
var foot:=Vector2.ZERO
func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_theme_font_override("font",preload("res://assets/fonts/DearRounded.tres"))
	add_theme_font_size_override("font_size",25)
	add_theme_color_override("font_color",Color("493c30"))
	add_theme_color_override("font_shadow_color",Color("fff9ee"))
	add_theme_constant_override("shadow_offset_x",1)
	add_theme_constant_override("shadow_offset_y",1)
	horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	z_index=3;modulate.a=0.0
func _process(delta:float)->void:
	var nearby:=is_instance_valid(courier) and courier.visible and absf(courier.foot.x-foot.x)<430.0
	modulate.a=move_toward(modulate.a,1.0 if nearby else 0.0,delta*5.0)
