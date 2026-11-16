extends Control
## Shared scene transition layer.
##
## Long transitions use the supplied cover with a small transparent figure
## and caption at the lower right. Short scene swaps
## crossfade directly from the previous framebuffer; no paper flash.

const FRAME_PATHS := [
    "res://assets/authoring/loading_20261114/frame_00.png",
    "res://assets/authoring/loading_20261114/frame_01.png",
    "res://assets/authoring/loading_20261114/frame_02.png",
    "res://assets/authoring/loading_20261114/frame_03.png",
    "res://assets/authoring/loading_20261114/frame_04.png",
    "res://assets/authoring/loading_20261114/frame_05.png",
]
const COVER_TEXTURE_PATH := "res://assets/display_user/dear_somewhere_cover_USER_20261024.png"
const FONT := preload("res://assets/fonts/DearRounded.tres")
var locale := "zh"

var loading_enabled := true:
    set(value):
        loading_enabled = bool(value)
        _sync_visibility()
var coverage := 0.0:
    set(value):
        coverage = clampf(float(value), 0.0, 1.0)
        _sync_visibility()
        queue_redraw()
var progress := 0.0:
    set(value):
        progress = clampf(float(value), 0.0, 1.0)
        queue_redraw()
var sound: Node
var _frames: Array[Texture2D] = []
var _frame_time := 0.0
var _cover: TextureRect
var _art: TextureRect
var _caption: Label
var _snapshot: TextureRect

func _ready() -> void:
    name = "SceneTransition"
    z_index = 200
    mouse_filter = Control.MOUSE_FILTER_STOP
    for path in FRAME_PATHS:
        var source := load(path) as Texture2D
        if source != null:
            var pixels := source.get_image()
            pixels.convert(Image.FORMAT_RGBA8)
            pixels.premultiply_alpha()
            pixels.generate_mipmaps()
            _frames.append(ImageTexture.create_from_image(pixels))

    _snapshot = TextureRect.new()
    _snapshot.name = "PreviousScene"
    _snapshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _snapshot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_snapshot)

    _cover = TextureRect.new()
    _cover.name = "LoadingCover"
    var cover_pixels := Image.load_from_file(COVER_TEXTURE_PATH)
    if cover_pixels != null:
        _cover.texture = ImageTexture.create_from_image(cover_pixels)
    _cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _cover.stretch_mode = TextureRect.STRETCH_SCALE
    _cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_cover)

    _art = TextureRect.new()
    _art.name = "SuppliedLoadingLineArt"
    _art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_art)

    var blend := CanvasItemMaterial.new()
    blend.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
    _art.material = blend
    _art.texture = _frames[0] if not _frames.is_empty() else null
    _caption = Label.new()
    _caption.name = "LoadingCaption"
    _caption.text = "Loading…" if locale == "en" else "加载中…"
    _caption.add_theme_font_override("font",FONT)
    _caption.add_theme_color_override("font_color",Color("fff9ee"))
    _caption.add_theme_color_override("font_shadow_color",Color(0.05,0.12,0.16,.65))
    _caption.add_theme_constant_override("shadow_offset_y",2)
    _caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_caption)
    _layout()
    _sync_visibility()
    queue_redraw()

func _process(delta: float) -> void:
    _frame_time = fposmod(_frame_time + delta, 1.2)
    if not _frames.is_empty() and is_instance_valid(_art):
        _art.texture = _frames[mini(_frames.size() - 1, int(_frame_time / 0.2))]
    _sync_visibility()
    _layout()
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _layout()

func _layout() -> void:
    if not is_instance_valid(_cover):return
    _cover.position = Vector2.ZERO
    _cover.size = size
    _snapshot.position = Vector2.ZERO
    _snapshot.size = size
    var unit := minf(size.x / 1600.0,size.y / 900.0)
    # One quiet lower-right group; a fixed caption avoids rhythmic layout jumps.
    _art.size = Vector2(110,176)*unit
    _art.position = size-Vector2(340,208)*unit
    _caption.position = size-Vector2(218,100)*unit
    _caption.size = Vector2(186,56)*unit
    _caption.add_theme_font_size_override("font_size",roundi(28*unit))

func _sync_visibility() -> void:
    var shown := coverage > 0.002
    for child in [_cover,_art,_caption]:
        if is_instance_valid(child):
            child.visible = shown and loading_enabled
            child.modulate.a = coverage
    if is_instance_valid(_snapshot):
        _snapshot.visible = shown and not loading_enabled
        _snapshot.modulate.a = coverage

func set_loading_enabled(enabled: bool) -> void:
    loading_enabled = enabled
    _sync_visibility()

func set_progress(value: float) -> void:
    progress = value

func cover(show_loading: bool = true) -> void:
    set_loading_enabled(show_loading)
    if not show_loading:
        # Freeze the current scene, build the destination behind it, then blend
        # the two scenes. This avoids a light-colored flash on every doorway.
        coverage = 0.0
        await get_tree().process_frame
        if DisplayServer.get_name() != "headless":
            await RenderingServer.frame_post_draw
            var image := get_viewport().get_texture().get_image()
            if not image.is_empty():
                _snapshot.texture = ImageTexture.create_from_image(image)
        coverage = 1.0
        return
    _frame_time = 0.0
    progress = 0.12
    if is_instance_valid(sound):
        sound.play("flip")
    var motion := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    motion.tween_property(self, "coverage", 1.0, 0.38)
    await motion.finished

func uncover(show_loading: bool = true) -> void:
    set_loading_enabled(show_loading)
    progress = 1.0
    await get_tree().process_frame
    if DisplayServer.get_name() != "headless":
        await RenderingServer.frame_post_draw
    var motion := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    motion.tween_property(self, "coverage", 0.0, 0.50 if show_loading else 0.38)
    await motion.finished
