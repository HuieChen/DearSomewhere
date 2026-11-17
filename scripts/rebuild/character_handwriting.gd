extends RefCounted
## Individual writing profiles, informed by NPC DESIGN V7 and user overrides.
## Font files remain original OFL bytes. Variation is applied only at rendering.
const PEN=preload("res://assets/fonts/handwriting/LXGWWenKaiTC-Regular.ttf")
const FINE=preload("res://assets/fonts/handwriting/LXGWWenKaiTC-Light.ttf")
const LOOSE=preload("res://assets/fonts/handwriting/LongCang-Regular.ttf")
const BRUSH=preload("res://assets/fonts/handwriting/MaShanZheng-Regular.ttf")
const ROCK=preload("res://assets/fonts/handwriting/ZhiMangXing-Regular.ttf")
const ROUND=preload("res://assets/fonts/ZCOOLKuaiLe.ttf")
const MARKER=preload("res://assets/fonts/handwriting/LXGWMarkerGothic-Regular.ttf")
const LATIN=preload("res://assets/fonts/Caveat.ttf")
const FALLBACK=preload("res://assets/fonts/NotoSansSC.ttf")
const Effect=preload("res://scripts/rebuild/handwriting_effect.gd")
const ALIASES={"主角":"Anne","你":"Anne","我":"Anne","You":"Anne","Cici":"cici","巫巫":"cici","石泳琪":"咸鱼","餐车摊主":"咸鱼","餐车老板":"咸鱼","Chef":"咸鱼","塔罗师":"夏透明","Monssner":"Mossner","黄毛乐队男":"guitarist","吉他手":"guitarist","Guitarist":"guitarist","老爷爷":"Arthur"}
# font, size, ink, horizontal scale, pen slant, spacing, baseline variation,
# pressure variation, embolden, line spacing. All distances use 1600x900 UI units.
const PROFILES={
	"Anne":[MARKER,28,"50464a",1.00,.005,.5,.03,.005,.0,9],
	"cici":[MARKER,28,"594950",1.02,-.010,1.0,.06,.008,.0,9],
	"Maya":[PEN,28,"303e44",1.00,.015,1.0,.02,.005,.0,9],
	"Rae":[PEN,28,"344748",.97,.025,1.0,.02,.005,.0,10],
	"guitarist":[PEN,28,"3e4042",1.02,.035,.4,.08,.01,.06,9],
	"Arthur":[PEN,28,"54483f",1.00,-.010,1.0,.12,.015,.0,10],
	"Mossner":[PEN,28,"41464a",1.00,.010,1.0,.02,.005,.0,9],
	"Xanni":[PEN,28,"4e444c",1.00,.025,.5,.06,.01,.0,9],
	"尘缘":[PEN,28,"454950",.99,-.010,.5,.04,.005,.0,9],
	"冥冥":[PEN,28,"514b54",.99,-.010,1.0,.05,.01,.0,10],
	"周晓六":[PEN,28,"514c47",1.00,-.015,.5,.06,.01,.0,10],
	"BEETMAN":[PEN,28,"444b40",1.02,.010,.5,.05,.01,.04,9],
	"夏透明":[PEN,28,"4b4652",1.00,.010,1.0,.03,.005,.0,10],
	"宇星晴":[PEN,28,"434d57",.99,-.005,1.0,.03,.005,.0,10],
	"咸鱼":[PEN,28,"55473e",1.02,.020,.5,.06,.01,.04,9],
	"闹闹":[PEN,28,"50464d",1.00,-.020,.5,.06,.01,.02,9],
	"Theo":[PEN,28,"404b42",.99,.015,.5,.03,.005,.02,9]
}
static var _fonts:Dictionary={}
static func identity(speaker:String)->String:
	return str(ALIASES.get(speaker,speaker))
static func profile(speaker:String)->Array:
	return PROFILES.get(identity(speaker),[PEN,28,"493c30",1.0,.0,.6,.1,.025,.0,9])
static func font_for(speaker:String)->FontVariation:
	var key:=identity(speaker)
	if _fonts.has(key):return _fonts[key]
	var p:=profile(key)
	var font:=FontVariation.new()
	font.base_font=p[0]
	font.fallbacks=[PEN,LATIN,FALLBACK]
	font.variation_transform=Transform2D(Vector2(float(p[3]),0.0),Vector2(-float(p[4]),1.0),Vector2.ZERO)
	font.variation_embolden=float(p[8])
	font.spacing_glyph=int(round(float(p[5])))
	font.spacing_space=2
	_fonts[key]=font
	return font
static func apply(body:RichTextLabel,name_label:Label,speaker:String,text:String)->void:
	var p:=profile(speaker)
	var font:=font_for(speaker)
	body.add_theme_font_override("normal_font",font)
	body.add_theme_font_size_override("normal_font_size",int(p[1]))
	body.add_theme_color_override("default_color",Color(str(p[2])))
	body.add_theme_constant_override("line_separation",int(p[9]))
	body.text=""
	body.bbcode_enabled=true
	body.custom_effects=[]
	var effect:=Effect.new()
	effect.baseline=float(p[6]);effect.pressure=float(p[7]);effect.seed_value=float(identity(speaker).hash()%997)
	body.install_effect(effect)
	# Keep the backing text synchronized: a deferred theme/layout refresh can
	# otherwise restore an earlier .text value after incremental add_text calls.
	# Escape every opening bracket so manuscript text cannot add BBCode tags.
	body.text="[hand]"+text.replace("[","[lb]")+"[/hand]"
	name_label.add_theme_font_override("font",font)
	name_label.add_theme_font_size_override("font_size",23)
	name_label.add_theme_color_override("font_color",Color(str(p[2])))
