extends RefCounted
## Exact supplied PNGs; atlas bounds omit only distant paint marks.
const MANIFEST = "res://assets/authoring/cast_20261119/provenance.json"
const PORTRAITS = {"Mossner":"mossner_portrait", "Monssner":"mossner_portrait", "周晓六":"zhou_portrait", "宇星晴":"yu_portrait", "BEETMAN":"beetman_portrait", "南星":"nanxing_smile"}
const CHIBIS = {"周晓六":"zhou_chibi", "宇星晴":"yu_chibi"}
static var entries:Dictionary = {}
static var cache:Dictionary = {}

static func portrait_key(speaker:String)->String:
	return "supplied/"+str(PORTRAITS[speaker]) if PORTRAITS.has(speaker) else ""

static func texture(key:String)->Texture2D:
	key=key.trim_prefix("supplied/")
	if cache.has(key):return cache[key]
	if entries.is_empty():
		var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		entries=data.assets
	if not entries.has(key):return null
	var entry:Dictionary=entries[key]
	var pixels:=Image.load_from_file(str(entry.path))
	if pixels==null:return null
	pixels.generate_mipmaps()
	var atlas:=AtlasTexture.new()
	atlas.atlas=ImageTexture.create_from_image(pixels)
	var r:Array=entry.region
	atlas.region=Rect2(r[0],r[1],r[2],r[3]);atlas.filter_clip=true
	cache[key]=atlas
	return atlas
