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
    background.color = Color.WHITE
    background.size = Vector2(1600, 900)
    viewport.add_child(background)
    var overlay = load("res://scripts/ui/scene_passage.gd").new()
    overlay.size = Vector2(1600, 900)
    viewport.add_child(overlay)
    await process_frame
    check(overlay._frames.size() == 6, "six supplied loading frames loaded")
    check(overlay._frames[0].get_width() > 0, "loading frame has pixels")
    check(overlay._caption.text == "加载中…", "Chinese loading caption")
    check(overlay._art.modulate.a == 0.0 and overlay._caption.modulate.a == 0.0, "new transition begins fully transparent")
    overlay.locale = "en"
    check(overlay._caption.text == "Loading…", "English loading caption updates")
    overlay.coverage = 1.0
    overlay.set_progress(0.65)
    await process_frame
    check(is_equal_approx(overlay.progress, 0.65), "progress value is exposed")
    if DisplayServer.get_name() != "headless":
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
        check(absf(half_pixel.get_luminance() - full_pixel.get_luminance()) > 0.03, "progress track opacity changes with coverage")
        check(clear_pixel.get_luminance() > 0.99, "progress track leaves no residue on destination")
    await overlay.cover()
    check(overlay.coverage > 0.99, "cover reaches opaque state")
    await overlay.uncover()
    check(overlay.coverage < 0.01, "uncover returns to gameplay")
    check(overlay._art.modulate.a < 0.01 and overlay._caption.modulate.a < 0.01, "all children are transparent when uncover finishes")
    var receipt := {"checks": checks, "failures": failures, "frames": overlay._frames.size(), "display": DisplayServer.get_name(), "method": "scene_passage lifecycle, bilingual captions and GPU fade readback when available"}
    var out := "user://loading-transition-20261114.json"
    if not output_directory.is_empty():
        DirAccess.make_dir_recursive_absolute(output_directory)
        out = output_directory.path_join("receipt.json")
    var file := FileAccess.open(out, FileAccess.WRITE)
    file.store_string(JSON.stringify(receipt))
    file.close()
    print("LOADING_TRANSITION_20261114 ", JSON.stringify(receipt))
    viewport.queue_free()
    await process_frame
    quit(1 if not failures.is_empty() else 0)
