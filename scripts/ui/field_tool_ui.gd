extends RefCounted
## Shared camera/recorder scale and placement on the 1600x900 stage.
const Paper=preload("res://scripts/ui/paper_ui.gd")
const FONT=preload("res://assets/fonts/DearRounded.tres")
const TITLE:=Rect2(80,60,300,42)
const STATUS:=Rect2(640,65,320,38)
const FIRST_ACTION:=Rect2(90,124,210,38)
const SECOND_ACTION:=Rect2(316,124,190,38)
const CLOSE:=Rect2(1496,48,48,46)
const TRIGGER:=Rect2(756,732,88,88)
const TRIGGER_HINT:=Rect2(755,831,90,26)
const LOCATION:=Rect2(270,800,430,38)

static func button(parent:Node,text:String,rect:Rect2,font_size:int=20)->Button:
	var value:=Button.new();value.text=text
	Paper.apply_button_style(value)
	value.add_theme_font_size_override("font_size",font_size)
	Paper.place(value,parent,rect)
	return value

static func label(parent:Node,text:String,rect:Rect2,font_size:int,align:HorizontalAlignment=HORIZONTAL_ALIGNMENT_LEFT)->Label:
	var value:=Label.new();value.text=text;value.horizontal_alignment=align;value.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;value.mouse_filter=Control.MOUSE_FILTER_IGNORE
	value.add_theme_font_override("font",FONT);value.add_theme_font_size_override("font_size",font_size);value.add_theme_color_override("font_color",Color("fff5dc"));value.add_theme_color_override("font_shadow_color",Color(0.25,0.25,0.19,0.8));value.add_theme_constant_override("shadow_offset_x",1);value.add_theme_constant_override("shadow_offset_y",2)
	Paper.place(value,parent,rect)
	return value
