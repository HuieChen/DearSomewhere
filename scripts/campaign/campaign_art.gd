extends RefCounted
const PATH="res://data/campaign/presentation.json"
static var bindings:Dictionary={}
static var textures:Dictionary={}
static func get_binding(key:String,fallback:Variant="")->Variant:
    if bindings.is_empty():
        var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(PATH))
        if parsed is Dictionary:bindings=parsed
    return bindings.get(key,fallback)
static func texture(key:String)->Texture2D:
    var path:String=str(get_binding(key))
    if path.is_empty():return null
    if textures.has(path):return textures[path]
    var pixels:=Image.load_from_file(path)
    if pixels==null or pixels.is_empty():return null
    textures[path]=ImageTexture.create_from_image(pixels)
    return textures[path]
