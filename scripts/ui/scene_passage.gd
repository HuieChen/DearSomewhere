extends Control
## Shared loading/transition layer. The supplied line animation is kept as-is;
## this controller only keys its black matte and animates the surrounding UI.

const FRAME_PATHS := [
    "res://assets/authoring/loading_20261114/frame_00.png",
    "res://assets/authoring/loading_20261114/frame_01.png",
    "res://assets/authoring/loading_20261114/frame_02.png",
    "res://assets/authoring/loading_20261114/frame_03.png",
    "res://assets/authoring/loading_20261114/frame_04.png",
    "res://assets/authoring/loading_20261114/frame_05.png",
]

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
var _art: TextureRect
var _caption: Label

func _ready() -> void:
    name = "SceneTransition"
    z_index = 200
    mouse_filter = Control.MOUSE_FILTER_STOP
    for path in FRAME_PATHS:
        var texture := load(path) as Texture2D
        if texture != null: _frames.append(texture)
    _art = TextureRect.new()
    _art.name = "SuppliedLoadingLineArt"
    _art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _art.modulate = Color(1, 1, 1, 0.96)
    add_child(_art)
    _caption = Label.new()
    _caption.text = "加载中…"
    _caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _caption.add_theme_font_size_override("font_size", 26)
    _caption.add_theme_color_override("font_color", Color("#f7f4e9"))
    _caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_caption)
    _layout()
    queue_redraw()

func _process(delta: float) -> void:
    _frame_time = fposmod(_frame_time + delta, 1.2)
    if not _frames.is_empty():
        _art.texture = _frames[mini(_frames.size() - 1, int(_frame_time / 0.2))]
    # Fade every loading-layer child with the same coverage value. This keeps
    # the supplied line art untouched while preventing a caption/texture
    # ghost from remaining on the destination scene after uncover().
    if is_instance_valid(_art):
        _art.modulate.a = coverage * 0.96
    if is_instance_valid(_caption):
        _caption.modulate.a = coverage
    _layout()
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED: _layout()

func _layout() -> void:
    if not is_instance_valid(_art): return
    var canvas := size
    _art.position = Vector2(canvas.x * 0.5 - 125.0, canvas.y * 0.5 - 185.0)
    _art.size = Vector2(250.0, 250.0)
    _caption.position = Vector2(canvas.x * 0.5 - 230.0, canvas.y * 0.5 + 86.0)
    _caption.size = Vector2(460.0, 42.0)

func set_progress(value: float) -> void:
    progress = value

func _draw() -> void:
    var canvas := size
    var alpha := coverage * 0.94
    draw_rect(Rect2(Vector2.ZERO, canvas), Color(0.035, 0.075, 0.11, alpha))
    if alpha < 0.01: return
    var bar := Rect2(canvas.x * 0.13, canvas.y * 0.82, canvas.x * 0.74, 28.0)
    draw_style_box(_box(Color("#d7f3f4"), Color("#f8f5e9"), 5, 16), bar)
    var fill := Rect2(bar.position + Vector2(5, 5), Vector2(maxf(6.0, (bar.size.x - 10.0) * progress), bar.size.y - 10.0))
    draw_style_box(_box(Color("#238ed9"), Color("#238ed9"), 0, 11), fill)
    var shimmer_x := fposmod(Time.get_ticks_msec() / 900.0, 1.0) * fill.size.x
    if fill.size.x > 12.0:
        draw_line(fill.position + Vector2(shimmer_x, 4), fill.position + Vector2(shimmer_x, fill.size.y - 4), Color(0.78, 0.96, 1.0, 0.22), 3.0)

func _box(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = fill
    box.border_color = border
    box.set_border_width_all(border_width)
    box.set_corner_radius_all(radius)
    return box

func cover() -> void:
    _frame_time = 0.0
    progress = 0.12
    if is_instance_valid(sound): sound.play("flip")
    var motion := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    motion.tween_property(self, "coverage", 1.0, 0.24)
    await motion.finished

func uncover() -> void:
    progress = 1.0
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var motion := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    motion.tween_property(self, "coverage", 0.0, 0.38)
    await motion.finished
