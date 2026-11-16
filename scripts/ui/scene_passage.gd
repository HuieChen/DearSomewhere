extends Control
## Shared scene transition layer.
##
## Long transitions use the approved paper background and centered transparent
## figure with a plain Loading percentage. Short scene swaps
## crossfade directly from the previous framebuffer; no paper flash.

const FRAME_PATHS := [
    "res://assets/authoring/loading_20261114/frame_00.png",
    "res://assets/authoring/loading_20261114/frame_01.png",
    "res://assets/authoring/loading_20261114/frame_02.png",
    "res://assets/authoring/loading_20261114/frame_03.png",
    "res://assets/authoring/loading_20261114/frame_04.png",
    "res://assets/authoring/loading_20261114/frame_05.png",
]
const PAPER_TEXTURE_PATH := "res://assets/authoring/loading_20261114/paper_texture.png"
const FONT := preload("res://assets/fonts/Caveat.ttf")
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
        _refresh_caption()
        queue_redraw()
var sound: Node
var _frames: Array[Texture2D] = []
var _frame_time := 0.0
var _paper: TextureRect
var _art: TextureRect
var _caption: Label
var _snapshot: TextureRect

func _ready() -> void:
    name = "SceneTransition"
    z_index = 200
    mouse_filter = Control.MOUSE_FILTER_STOP
    for path in FRAME_PATHS:
        # HEVC decoder retained associated (premultiplied) RGB. Multiplying it
        # again darkens every antialiased stroke. Read original PNG pixels so
        # the texture importer's straight-alpha border repair cannot bleed RGB.
        var pixels := Image.load_from_file(path)
        if pixels != null and not pixels.is_empty():
            pixels.convert(Image.FORMAT_RGBA8)
            pixels.generate_mipmaps()
            _frames.append(ImageTexture.create_from_image(pixels))

    _snapshot = TextureRect.new()
    _snapshot.name = "PreviousScene"
    _snapshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _snapshot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_snapshot)

    _paper = TextureRect.new()
    _paper.name = "LoadingPaper"
    _paper.texture = load(PAPER_TEXTURE_PATH) as Texture2D
    _paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _paper.stretch_mode = TextureRect.STRETCH_TILE
    _paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var paper_material := ShaderMaterial.new()
    paper_material.shader = load("res://scripts/ui/cotton_paper.gdshader")
    _paper.material = paper_material
    add_child(_paper)

    _art = TextureRect.new()
    _art.name = "SuppliedLoadingLineArt"
    _art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_art)

    var blend := ShaderMaterial.new()
    blend.shader = preload("res://scripts/ui/loading_associated_alpha.gdshader")
    _art.material = blend
    _art.texture = _frames[0] if not _frames.is_empty() else null
    _caption = Label.new()
    _caption.name = "LoadingCaption"
    _caption.text = "Loading 0%"
    _caption.add_theme_font_override("font",FONT)
    _caption.add_theme_color_override("font_color",Color("0059ae"))
    _caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
    if not is_instance_valid(_paper):return
    _paper.position = Vector2.ZERO
    _paper.size = size
    _snapshot.position = Vector2.ZERO
    _snapshot.size = size
    var unit := minf(size.x / 1600.0,size.y / 900.0)
    var center := size*0.5
    _art.size = Vector2(400,550)*unit
    _art.position = center+Vector2(-200,-365)*unit
    _caption.position = center+Vector2(-200,220)*unit
    _caption.size = Vector2(400,56)*unit
    _caption.add_theme_font_size_override("font_size",roundi(36*unit))

func _refresh_caption() -> void:
    if is_instance_valid(_caption):
        _caption.text = "Loading %d%%" % roundi(progress*100.0)

func _sync_visibility() -> void:
    var shown := coverage > 0.002
    for child in [_paper,_art,_caption]:
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
