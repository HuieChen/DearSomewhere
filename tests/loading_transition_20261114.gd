extends SceneTree

var checks := 0
var failures: Array[String] = []
var output_directory := ""

func check(condition: bool, label: String) -> void:
    checks += 1
    if not condition: failures.append(label)

func _initialize() -> void:
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--qa-out="):
            output_directory = argument.trim_prefix("--qa-out=")
    run.call_deferred()

func run() -> void:
    root.size = Vector2i(1600, 900)
    root.unfocusable = true
    var viewport := SubViewport.new()
    viewport.size = Vector2i(1600, 900)
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var background := ColorRect.new()
    background.color = Color("#26494f")
    background.size = Vector2(1600, 900)
    viewport.add_child(background)
    var overlay = load("res://scripts/ui/scene_passage.gd").new()
    overlay.size = Vector2(1600, 900)
    viewport.add_child(overlay)
    await process_frame
    check(overlay._frames.size() == 6, "six supplied loading frames loaded")
    check(overlay._frames[0].get_width() > 0, "loading frame has pixels")
    check(not overlay._art.visible and not overlay._caption.visible, "new transition begins transparent")
    check(overlay._frames[0].get_width() < 900, "alpha-only common bounds exclude hidden RGB matte")
    var first_image:Image = overlay._frames[0].get_image()
    check(first_image.get_pixel(0,0).a < 0.01, "native transparent frame corner")
    check(absf(overlay._art.get_rect().get_center().x-800)<1, "transparent figure stays centered")
    check(overlay._art.size.y >= 500.0, "approved large figure composition")
    overlay.coverage = 1.0
    overlay.set_progress(0.65)
    check(is_equal_approx(overlay.progress, 0.65) and overlay._caption.text=="Loading 65%", "caption reflects supplied progress")
    check(overlay.find_child("SuppliedWaveLoadingBar",true,false)==null, "no wave distortion or progress strip remains")
    check(overlay._paper.texture != null, "approved paper background restored")
    if DisplayServer.get_name() != "headless":
        await process_frame
        RenderingServer.force_draw(false)
        var full_pixel := viewport.get_texture().get_image().get_pixel(1200, 752)
        overlay.coverage = 0.5
        await process_frame
        RenderingServer.force_draw(false)
        var half_pixel := viewport.get_texture().get_image().get_pixel(1200, 752)
        overlay.coverage = 0.0
        await process_frame
        RenderingServer.force_draw(false)
        var clear_pixel := viewport.get_texture().get_image().get_pixel(1200, 752)
        check(absf(half_pixel.get_luminance() - full_pixel.get_luminance()) > 0.03, "transition opacity changes with coverage")
        check(absf(clear_pixel.get_luminance() - background.color.get_luminance()) < 0.01, "destination pixels restored without residue")
    await overlay.cover()
    check(overlay.coverage > 0.99, "cover reaches opaque state")
    overlay.set_progress(0.82)
    if not output_directory.is_empty() and DisplayServer.get_name() != "headless":
        DirAccess.make_dir_recursive_absolute(output_directory)
        await create_timer(0.65).timeout
        RenderingServer.force_draw(false)
        viewport.get_texture().get_image().save_png(output_directory.path_join("loading.png"))
    for dims:Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440)]:
        overlay.size=Vector2(dims)
        overlay._layout()
        check(Rect2(Vector2.ZERO,overlay.size).encloses(overlay._art.get_rect()) and Rect2(Vector2.ZERO,overlay.size).encloses(overlay._caption.get_rect()),"centered group fits "+str(dims))
        check(not overlay._art.get_rect().intersects(overlay._caption.get_rect()),"figure and caption remain separate "+str(dims))
    overlay.size=Vector2(1600,900)
    overlay._layout()
    await overlay.uncover()
    check(overlay.coverage < 0.01 and overlay._caption.text=="Loading 100%", "uncover completes percentage and returns to gameplay")
    check(not overlay._caption.visible and not overlay._art.visible and not overlay._paper.visible, "all children disappear on the final fade frame")
    await overlay.cover(false)
    check(not overlay._art.visible and not overlay._caption.visible, "short transition skips loading composition")
    check(not overlay._paper.visible, "short transition never exposes loading cover")
    if DisplayServer.get_name() != "headless":
        check(overlay._snapshot.texture != null, "short transition retains previous framebuffer")
        background.color=Color("375b76")
        await process_frame
        RenderingServer.force_draw(false)
        var retained := viewport.get_texture().get_image().get_pixel(100,100)
        check(absf(retained.r-Color("26494f").r)<0.02, "previous scene retained over newly built scene")
    await overlay.uncover(false)
    check(overlay.coverage < 0.01 and not overlay._paper.visible, "short transition fully clears")
    var receipt := {"checks": checks, "failures": failures, "frames": overlay._frames.size(), "display": DisplayServer.get_name(), "method": "scene_passage lifecycle, supplied loading artwork, frame alpha/layout, snapshot crossfade and GPU fade readback"}
    var out := "user://loading-transition-20261114.json"
    if not output_directory.is_empty():
        DirAccess.make_dir_recursive_absolute(output_directory)
        out = output_directory.path_join("receipt.json")
    FileAccess.open(out, FileAccess.WRITE).store_string(JSON.stringify(receipt))
    print("LOADING_TRANSITION_20261114 ", JSON.stringify(receipt))
    viewport.queue_free()
    await process_frame
    quit(1 if not failures.is_empty() else 0)

