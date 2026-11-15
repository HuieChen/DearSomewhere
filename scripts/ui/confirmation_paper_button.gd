extends Button
## Match the authored Settings actions: ivory surface, blue live typography.
const FONT=preload("res://assets/fonts/DearRounded.tres")
var lift:=0.0:
    set(value):lift=value;queue_redraw()
var _hover:=false
var _motion:Tween
func _ready()->void:
    mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
    for state:String in ["normal","hover","pressed","focus","disabled"]:
        add_theme_stylebox_override(state,StyleBoxEmpty.new())
    for state:String in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color"]:
        add_theme_color_override(state,Color.TRANSPARENT)
    mouse_entered.connect(func():_hover=true;grab_focus();_settle())
    mouse_exited.connect(func():_hover=false;_settle())
    focus_entered.connect(_settle);focus_exited.connect(_settle)
    button_down.connect(_settle);button_up.connect(_settle)
    resized.connect(queue_redraw)
func _settle()->void:
    if _motion and _motion.is_valid():_motion.kill()
    var target:=1.0 if button_pressed else (-1.0 if has_focus() or _hover else 0.0)
    _motion=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _motion.tween_property(self,"lift",target,.08 if button_pressed else .14)
    queue_redraw()
func _draw()->void:
    var active:=has_focus() or _hover
    var surface:=StyleBoxFlat.new()
    surface.bg_color=Color("e3f1f6") if button_pressed else (Color("f4fbff") if active else Color("fff9ee"))
    surface.set_corner_radius_all(14)
    if has_focus():
        surface.border_color=Color("8ec5e3")
        surface.set_border_width_all(2)
    if disabled:surface.bg_color.a=.5
    draw_style_box(surface,Rect2(Vector2(0,lift),size))
    var font_size:=28
    while FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>size.x-40 and font_size>18:font_size-=1
    var width:=FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
    var baseline:=(size.y-FONT.get_height(font_size))*.5+FONT.get_ascent(font_size)+lift
    draw_string(FONT,Vector2((size.x-width)*.5,baseline),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("0059ae") if not disabled else Color("7798ae"))
