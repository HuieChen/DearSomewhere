extends Node
## Reduce rendering work when another application owns focus. Keep simulation,
## audio and save handling running, and retain the player's foreground limit.
const BACKGROUND_FPS := 20

var _enabled := false
var _limited := false
var _foreground_limit := 0
var _background_limit := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_enabled = not Engine.is_editor_hint() and DisplayServer.get_name() != "headless"
	# Unfocusable QA views and fixed-rate movie capture must keep their own clock.
	_enabled = _enabled and not get_window().unfocusable
	var args := OS.get_cmdline_args()
	if args.has("--write-movie") or args.has("--fixed-fps"):
		_enabled = false
	if _enabled:
		_sync_initial_focus.call_deferred()

func _sync_initial_focus() -> void:
	if is_inside_tree() and _enabled and not get_window().has_focus():
		_limit_background()

func _notification(what:int) -> void:
	if not _enabled:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_limit_background()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_restore_foreground()

func _limit_background() -> void:
	if _limited:
		return
	_foreground_limit = Engine.max_fps
	_background_limit = mini(_foreground_limit, BACKGROUND_FPS) if _foreground_limit > 0 else BACKGROUND_FPS
	_limited = true
	Engine.max_fps = _background_limit

func _restore_foreground() -> void:
	if not _limited:
		return
	# Respect another component explicitly changing the cap while in background.
	if Engine.max_fps == _background_limit:
		Engine.max_fps = _foreground_limit
	_limited = false

func _exit_tree() -> void:
	_restore_foreground()
