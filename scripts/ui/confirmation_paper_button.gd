extends Button
## The approved Settings action style, shared with every paper dialog.
const UI=preload("res://scripts/ui/paper_ui.gd")
func _ready()->void:
	UI.apply_button_style(self)
	add_theme_font_size_override("font_size",23)
	add_child(preload("res://scripts/ui/button_press_feedback.gd").new())
