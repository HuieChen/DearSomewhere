extends RichTextEffect
## Stable marks left on paper, never a time-driven shaking animation.
var bbcode := "hand"
var baseline := 0.0
var pressure := 0.0
var seed_value := 0.0
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var n := float(char_fx.relative_index) + seed_value
	var wave := sin(n * 2.399963) * .65 + sin(n * .719) * .35
	char_fx.offset += Vector2(sin(n * 1.337) * baseline * .15, wave * baseline)
	char_fx.color.a *= 1.0 - pressure * (.5 + .5 * sin(n * 1.93))
	return true
