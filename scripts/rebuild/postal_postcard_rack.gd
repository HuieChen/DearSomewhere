extends Control
## Hit-test the supplied card pixels after rail/telephone occlusion.
signal card_requested(card:Dictionary, origin:Rect2)
const MANIFEST := "res://assets/authoring/post_office_20261116/postcards/cards.json"
const SOURCE_SCALE := 0.75
var allowed:Callable
var cards:Array=[]
var held_id:=""
var patch:TextureRect
var hotspots:Array[Button]=[]
static var _textures:Dictionary={}

static func texture(path:String)->Texture2D:
	if not _textures.has(path):
		var pixels:=Image.load_from_file(path)
		if pixels==null:return null
		pixels.generate_mipmaps()
		_textures[path]=ImageTexture.create_from_image(pixels)
	return _textures[path]

class CardHotspot extends Button:
	var coverage:Image
	var ink:Texture2D
	var warmth:=0.0
	func _ready():
		flat=true;mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
		for state in ["normal","hover","pressed","focus","disabled"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	func _has_point(point:Vector2)->bool:
		if coverage==null or not Rect2(Vector2.ZERO,size).has_point(point):return false
		var at:=Vector2i(point/size*Vector2(coverage.get_size()))
		return coverage.get_pixelv(at).a>.35
	func _process(delta:float):
		var wanted:=1.0 if not disabled and (is_hovered() or has_focus()) else 0.0
		warmth=move_toward(warmth,wanted,delta*9.0);queue_redraw()
	func _draw():
		if warmth>0.001 and ink!=null:draw_texture_rect(ink,Rect2(Vector2.ZERO,size),false,Color(1,0.97,0.84,.16*warmth))

func _ready():
	name="PostcardRack";mouse_filter=Control.MOUSE_FILTER_IGNORE
	var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if not data is Dictionary:return
	cards=data.get("cards",[])
	patch=TextureRect.new();patch.name="LiftedCardBackground";patch.mouse_filter=Control.MOUSE_FILTER_IGNORE
	patch.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;patch.hide();add_child(patch)
	for record:Dictionary in cards:
		var box:Array=record.source_rect
		var button:=CardHotspot.new()
		button.name=str(record.id)
		button.coverage=Image.load_from_file(str(record.hit_mask))
		button.ink=texture(str(record.hit_mask))
		add_child(button)
		button.position=Vector2(box[0],box[1])*SOURCE_SCALE
		button.size=Vector2(box[2],box[3])*SOURCE_SCALE
		button.pressed.connect(func():
			if held_id.is_empty() and (not allowed.is_valid() or allowed.call()):card_requested.emit(record,button.get_global_rect()))
		hotspots.append(button)
		# Small source textures are ready before the player first lifts a card.
		texture(str(record.face));texture(str(record.removed_patch))

func _process(_delta:float):
	var blocked:bool=not held_id.is_empty() or (allowed.is_valid() and not allowed.call())
	for button:Button in hotspots:button.disabled=blocked

func set_held(id:String):
	held_id=id
	patch.hide()
	if id.is_empty():return
	for record:Dictionary in cards:
		if str(record.id)!=id:continue
		var box:Array=record.source_rect
		patch.texture=texture(str(record.removed_patch))
		patch.position=Vector2(box[0],box[1])*SOURCE_SCALE
		patch.size=Vector2(box[2],box[3])*SOURCE_SCALE
		patch.show()
		return
