extends Control
## Shared scene transition layer.
##
## Long transitions use the supplied cyan line animation plus the supplied
## wave loading-bar artwork on a warm cotton-paper surface. Short scene swaps
## can opt out of the loading composition and use only a quiet paper fade.

const FRAME_PATHS := [
    "res://assets/authoring/loading_20261114/frame_00.png",
    "res://assets/authoring/loading_20261114/frame_01.png",
    "res://assets/authoring/loading_20261114/frame_02.png",
    "res://assets/authoring/loading_20261114/frame_03.png",
    "res://assets/authoring/loading_20261114/frame_04.png",
    "res://assets/authoring/loading_20261114/frame_05.png",
]
const PAPER_TEXTURE_PATH := "res://assets/authoring/loading_20261114/paper_texture.png"
const BAR_TEXTURE_PATH := "res://assets/authoring/loading_20261114/loading_bar_source.png"
const BAR_SHADER_PATH := "res://scripts/ui/loading_bar_flow.gdshader"

var loading_enabled := true:
    set(value):
        loading_enabled = bool(value)
        _sync_visibility()
var coverage := 0.0:
    set(value):
        coverage = clampf(float(value), 0.0, 1.0)
        queue_redraw()
var progress := 0.0:
    set(value):
        progress = clampf(float(value), 0.0, 1.0)
        queue_redraw()
var sound: Node
var _frames: Array[Texture2D] = []
var _frame_time := 0.0
var _flow_time := 0.0
var _paper: TextureRect
var _art: TextureRect
var _bar: TextureRect

func _ready() -> void:
    name = "SceneTransition"
    z_index = 200
    mouse_filter = Control.MOUSE_FILTER_STOP
    for path in FRAME_PATHS:
        var texture := load(path) as Texture2D
        if texture != null:
            _frames.append(texture)

    _paper = TextureRect.new()
    _paper.name = "CottonPaperSurface"
    _paper.texture = load(PAPER_TEXTURE_PATH) as Texture2D
    _paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _paper.stretch_mode = TextureRect.STRETCH_TILE
    _paper.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_paper)

    _art = TextureRect.new()
    _art.name = "SuppliedLoadingLineArt"
    _art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_art)

    _bar = TextureRect.new()
    _bar.name = "SuppliedWaveLoadingBar"
    _bar.texture = load(BAR_TEXTURE_PATH) as Texture2D
    _bar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _bar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _bar.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    _bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var flow_shader := load(BAR_SHADER_PATH) as Shader
    if flow_shader != null:
        var material := ShaderMaterial.new()
        material.shader = flow_shader
        _bar.material = material
    add_child(_bar)
    _layout()
    _sync_visibility()
    queue_redraw()

func _process(delta: float) -> void:
    _flow_time = fposmod(_flow_time + delta, 1000.0)
    _frame_time = fposmod(_frame_time + delta, 1.2)
    if not _frames.is_empty() and is_instance_valid(_art):
        _art.texture = _frames[mini(_frames.size() - 1, int(_frame_time / 0.2))]
    if is_instance_valid(_bar) and _bar.material is ShaderMaterial:
        (_bar.material as ShaderMaterial).set_shader_parameter("flow_time", _flow_time)
    _sync_visibility()
    _layout()
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _layout()

func _layout() -> void:
    if not is_instance_valid(_paper):
        return
    var canvas := size
    _paper.position = Vector2.ZERO
    _paper.size = canvas
    _art.position = Vector2(canvas.x * 0.5 - 145.0, canvas.y * 0.5 - 250.0)
    _art.size = Vector2(290.0, 290.0)
    _bar.position = Vector2(canvas.x * 0.5 - 380.0, canvas.y * 0.5 - 10.0)
    _bar.size = Vector2(760.0, 253.0)

func _sync_visibility() -> void:
    var visible := coverage > 0.002
    if is_instance_valid(_paper):
        _paper.visible = visible
        _paper.modulate.a = coverage * 0.08
    if is_instance_valid(_art):
        _art.visible = visible and loading_enabled
        _art.modulate.a = coverage * 0.96
    if is_instance_valid(_bar):
        _bar.visible = visible and loading_enabled
        _bar.modulate.a = coverage

func set_loading_enabled(enabled: bool) -> void:
    loading_enabled = enabled
    _sync_visibility()

func set_progress(value: float) -> void:
    progress = value

func _draw() -> void:
    # Warm fallback under the tiled texture keeps the transition paper-like even
    # for the first frame before the texture import is ready.
    var paper_alpha := coverage
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.965, 0.935, 0.865, paper_alpha))

func cover(show_loading: bool = true) -> void:
    set_loading_enabled(show_loading)
    _frame_time = 0.0
    _flow_time = 0.0
    progress = 0.12
    if is_instance_valid(sound):
        sound.play("flip" if show_loading else "paper")
    var duration := 0.34 if show_loading else 0.14
    var motion := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    motion.tween_property(self, "coverage", 1.0, duration)
    await motion.finished

func uncover(show_loading: bool = true) -> void:
    set_loading_enabled(show_loading)
    progress = 1.0
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var duration := 0.46 if show_loading else 0.20
    var motion := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    motion.tween_property(self, "coverage", 0.0, duration)
    await motion.finished
