class_name PaperUI
extends RefCounted

const INK = Color("4f3847")
const PAPER = Color("fff1df")
const TEAL = Color("0059ae")
const MUTED = Color("7c7378")
const CORAL = Color("bc416b")

static func place(node: Control, parent: Node, rect: Rect2) -> Control:
	parent.add_child(node)
	node.position = rect.position
	node.size = rect.size
	return node

static func style(color: Color, border: Color = Color.TRANSPARENT, radius: int = 4) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

static func panel(parent: Node, rect: Rect2, color: Color = PAPER) -> Panel:
	var p = Panel.new()
	p.add_theme_stylebox_override("panel", style(color, Color("d8d3bf")))
	place(p, parent, rect)
	return p

static func label(parent: Node, text: String, rect: Rect2, font_size: int = 22, color: Color = INK) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", font_size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(l, parent, rect)
	return l

static func body(parent: Node, text: String, rect: Rect2, font_size: int = 23) -> RichTextLabel:
	var l = RichTextLabel.new()
	l.text = text
	l.add_theme_color_override("default_color", INK)
	l.add_theme_font_size_override("normal_font_size", font_size)
	l.add_theme_constant_override("line_separation", 9)
	l.selection_enabled = true
	l.scroll_active = true
	place(l, parent, rect)
	return l

# Approved Settings reference: cream surface, blue type, restrained rounding.
const ACTION_PAPER = Color("fff9ee")
const ACTION_INK = Color("0059ae")
const ACTION_HOVER = Color("eaf3f8")
const ACTION_PRESSED = Color("dcebf4")
const ACTION_FONT = preload("res://assets/fonts/DearRounded.tres")

static func apply_button_style(button:BaseButton, embedded:bool=false)->void:
	button.add_theme_font_override("font",ACTION_FONT)
	button.add_theme_constant_override("outline_size",0)
	button.add_theme_color_override("font_color",ACTION_INK)
	button.add_theme_color_override("font_hover_color",Color("0874c2"))
	button.add_theme_color_override("font_pressed_color",Color("004d96"))
	button.add_theme_color_override("font_hover_pressed_color",Color("004d96"))
	button.add_theme_color_override("font_focus_color",ACTION_INK)
	button.add_theme_color_override("font_disabled_color",Color("8b9eab"))
	for state:String in ["normal","hover","pressed","hover_pressed","disabled"]:
		var fill:Color=ACTION_PAPER
		if embedded:fill=Color.TRANSPARENT
		if state=="hover":fill=ACTION_HOVER
		elif state in ["pressed","hover_pressed"]:fill=ACTION_PRESSED
		elif state=="disabled" and not embedded:fill=Color("f1eee6")
		var box:=style(fill,Color.TRANSPARENT,14)
		box.set_border_width_all(0)
		box.content_margin_left=8;box.content_margin_right=8
		box.content_margin_top=0;box.content_margin_bottom=0
		button.add_theme_stylebox_override(state,box)
	var focus:=style(Color.TRANSPARENT,Color("75add1"),14)
	focus.set_border_width_all(2)
	focus.content_margin_left=0;focus.content_margin_right=0
	focus.content_margin_top=0;focus.content_margin_bottom=0
	button.add_theme_stylebox_override("focus",focus)
	button.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state:String in ["icon_normal_color","icon_hover_color","icon_pressed_color","icon_focus_color"]:button.add_theme_color_override(state,ACTION_INK)
	if button is OptionButton:
		var menu:PopupMenu=button.get_popup()
		menu.add_theme_font_override("font",ACTION_FONT)
		menu.add_theme_font_size_override("font_size",21)
		menu.add_theme_color_override("font_color",ACTION_INK)
		menu.add_theme_color_override("font_hover_color",ACTION_INK)
		menu.add_theme_stylebox_override("panel",style(ACTION_PAPER,Color("dcebf4"),14))
		menu.add_theme_stylebox_override("hover",style(ACTION_HOVER,Color.TRANSPARENT,8))

static func button(parent: Node, text: String, rect: Rect2, callback: Callable, primary: bool = false) -> Button:
	var b = Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 21)
	apply_button_style(b)
	if text=="×":
		b.add_theme_font_size_override("font_size",32)
		b.action_mode=BaseButton.ACTION_MODE_BUTTON_PRESS
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	place(b, parent, rect)
	b.pivot_offset = rect.size * 0.5
	b.add_child(preload("res://scripts/ui/button_press_feedback.gd").new())
	b.mouse_entered.connect(func():_play_sound(b,"title_hover"))
	b.pressed.connect(func():_play_sound(b,"paper"))
	b.pressed.connect(callback)
	return b

static func _play_sound(node: Node, kind: String) -> void:
	var current: Node = node
	while current != null:
		var candidate: Variant = current.get("sound")
		if candidate is Node and candidate.has_method("play"):
			candidate.play(kind)
			return
		current = current.get_parent()

static func texture(parent: Node, path: String, rect: Rect2) -> TextureRect:
	var t = TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		t.texture = load(path)
	place(t, parent, rect)
	return t
