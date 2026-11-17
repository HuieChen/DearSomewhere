extends SceneTree
const Budget = preload("res://scripts/ui/background_frame_budget.gd")
var checks := 0
var failures:Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func check(ok:bool, message:String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var initial_cap := Engine.max_fps
	var physics_rate := Engine.physics_ticks_per_second
	var time_scale := Engine.time_scale
	var budget := Budget.new()
	root.add_child(budget)
	# Exercise OS notification handling in a deterministic headless regression;
	# real desktop focus delivery is verified separately in the player package.
	budget._enabled = true
	for limit:int in [0, 60, 144, 10]:
		Engine.max_fps = limit
		budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		check(Engine.max_fps == (20 if limit == 0 else mini(limit,20)), "background cap respects existing lower limit")
		budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		check(Engine.max_fps == limit, "duplicate focus-out preserves foreground cap")
		budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		check(Engine.max_fps == limit, "duplicate focus-in is harmless")
	Engine.max_fps = 144
	budget.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(Engine.max_fps == 144, "focus transfer inside app does not throttle")
	paused = true
	budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(Engine.max_fps == 20 and paused, "paused tree retains pause state and accepts budget")
	budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(Engine.max_fps == 144 and paused, "focus restoration does not resume a paused game")
	paused = false
	budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	Engine.max_fps = 30
	budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(Engine.max_fps == 30, "explicit external cap change is preserved")
	budget.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	budget.free()
	check(Engine.max_fps == 30, "host teardown restores the foreground cap")
	check(Engine.physics_ticks_per_second == physics_rate and Engine.time_scale == time_scale, "simulation speed and physics frequency are unchanged")
	var skipped := Budget.new()
	root.unfocusable = true
	root.add_child(skipped)
	skipped.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(Engine.max_fps == 30, "unfocusable QA does not change frame timing")
	skipped.free()
	Engine.max_fps = initial_cap
	print("BACKGROUND_FRAME_BUDGET ", checks, " checks / ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
