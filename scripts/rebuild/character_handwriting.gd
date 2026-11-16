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
	"Anne":[ROUND,27,"554451",1.00,.015,.6,.22,.035,.0,8],
	"cici":[MARKER,29,"634753",1.03,-.025,1.25,.48,.065,.08,9],
	"Maya":[PEN,28,"263c4c",1.00,.035,.95,.08,.025,.0,9],
	"Rae":[FINE,29,"29474b",.92,.085,1.55,.09,.02,.04,10],
	"guitarist":[ROCK,31,"36373d",1.02,.09,-.15,.65,.08,.16,10],
	"Arthur":[BRUSH,28,"634d3d",.97,-.025,1.10,.52,.115,-.06,10],
	"Mossner":[PEN,27,"39444b",1.01,.015,.85,.10,.025,.08,9],
	"Xanni":[LOOSE,31,"51404e",1.02,.045,.55,.36,.06,.12,9],
	"尘缘":[PEN,27,"454a56",.98,-.015,.25,.20,.04,.02,8],
	"冥冥":[FINE,29,"555061",.97,-.035,.70,.33,.07,.09,9],
	"周晓六":[LOOSE,30,"59534b",1.00,-.035,.80,.40,.065,.05,10],
	"BEETMAN":[PEN,28,"424c3b",1.05,.025,.10,.30,.06,.20,8],
	"夏透明":[FINE,29,"4b455b",.98,.015,1.15,.16,.045,.05,11],
	"宇星晴":[PEN,27,"435263",.96,-.01,1.50,.12,.04,.0,11],
	"咸鱼":[LOOSE,31,"654739",1.04,.02,.25,.42,.055,.30,9],
	"闹闹":[ROCK,30,"574252",.99,-.045,.65,.32,.07,.08,10],
	"Theo":[PEN,28,"39453d",.95,.045,.35,.18,.03,.18,8]
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
