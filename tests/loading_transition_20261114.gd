extends SceneTree

var checks := 0
var failures: Array[String] = []

func check(condition: bool, label: String) -> void:
    checks += 1
    if not condition: failures.append(label)

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    root.size = Vector2i(1600, 900)
    var overlay = load("res://scripts/ui/scene_passage.gd").new()
    root.add_child(overlay)
    await process_frame
    check(overlay._frames.size() == 6, "six supplied loading frames loaded")
    check(overlay._frames[0].get_width() > 0, "loading frame has pixels")
    overlay.coverage = 1.0
    overlay.set_progress(0.65)
    await process_frame
    check(is_equal_approx(overlay.progress, 0.65), "progress value is exposed")
    await overlay.cover()
    check(overlay.coverage > 0.99, "cover reaches opaque state")
    await overlay.uncover()
    check(overlay.coverage < 0.01, "uncover returns to gameplay")
    var receipt := {"checks": checks, "failures": failures, "frames": overlay._frames.size(), "method": "headless scene_passage lifecycle"}
    var out := "user://loading-transition-20261114.json"
    var file := FileAccess.open(out, FileAccess.WRITE)
    file.store_string(JSON.stringify(receipt))
    file.close()
    print("LOADING_TRANSITION_20261114 ", JSON.stringify(receipt))
    quit(1 if not failures.is_empty() else 0)
