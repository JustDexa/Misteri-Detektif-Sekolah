extends RefCounted
## Fungsi bantu pembuatan elemen UI pixel art.

const FX = preload("res://scripts/fx.gd")
const MENU := "res://assets/menu/"
const UI := "res://assets/ui/"

const C_CHOC := Color("3e2731")
const C_CREAM := Color("ead4aa")
const C_WHITE := Color("ffffff")
const C_NAVY := Color("262b44")
const C_RUST := Color("be4a2f")
const C_RED_D := Color("a22633")
const C_GOLD := Color("feae34")
const C_TAN := Color("e4a672")
const C_BLACK := Color("181425")
const C_GREY := Color("8b9bb4")


static func tex(path: String) -> Texture2D:
	return load(path)


static func atlas(path: String, frame: int, fw: int, fh: int) -> AtlasTexture:
	var a := AtlasTexture.new()
	a.atlas = load(path)
	a.region = Rect2(frame * fw, 0, fw, fh)
	return a


static func rect(parent: Node, path: String, pos: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.texture = load(path)
	r.position = pos
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


static func nine(parent: Node, path: String, margin: int, pos: Vector2, size: Vector2) -> NinePatchRect:
	var n := NinePatchRect.new()
	n.texture = load(path)
	n.patch_margin_left = margin
	n.patch_margin_right = margin
	n.patch_margin_top = margin
	n.patch_margin_bottom = margin
	n.position = pos
	n.size = size
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(n)
	return n


static func label(parent: Node, text: String, pos: Vector2, color := C_WHITE, width := 0.0,
		align := HORIZONTAL_ALIGNMENT_LEFT, shadow := Color(0, 0, 0, 0)) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("line_spacing", 0)
	if shadow.a > 0.0:
		l.add_theme_color_override("font_shadow_color", shadow)
		l.add_theme_constant_override("shadow_offset_x", 0)
		l.add_theme_constant_override("shadow_offset_y", 1)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if width > 0.0:
		l.size = Vector2(width, 11)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	if width > 0.0:
		l.size = Vector2(width, l.size.y)
	return l


## Tombol dari tiga gambar: <nama>_normal / _hover / _pressed di folder menu.
static func button(parent: Node, name: String, pos: Vector2, cb: Callable) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load(MENU + "ui_g_btn_%s_normal.png" % name)
	b.texture_hover = load(MENU + "ui_g_btn_%s_hover.png" % name)
	b.texture_pressed = load(MENU + "ui_g_btn_%s_pressed.png" % name)
	b.position = pos
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.mouse_entered.connect(func(): Game.sfx("sfx_hover"))
	b.mouse_entered.connect(FX.lift.bind(b, true))
	b.mouse_exited.connect(FX.lift.bind(b, false))
	b.pressed.connect(func(): Game.sfx("sfx_klik"))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


static func tex_button(parent: Node, normal: String, hover: String, pos: Vector2, cb: Callable) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load(normal)
	b.texture_hover = load(hover)
	b.position = pos
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.mouse_entered.connect(func(): Game.sfx("sfx_hover"))
	b.mouse_entered.connect(FX.lift.bind(b, true))
	b.mouse_exited.connect(FX.lift.bind(b, false))
	b.pressed.connect(func(): Game.sfx("sfx_klik"))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


static func dim(parent: Node, alpha := 0.55) -> ColorRect:
	var c := ColorRect.new()
	c.color = Color(0.094, 0.078, 0.145, alpha)
	c.size = Vector2(320, 180)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(c)
	return c


## Bungkus teks menjadi beberapa baris berdasarkan lebar piksel font.
static func wrap(text: String, width: float, font: Font, size := 9) -> PackedStringArray:
	var out := PackedStringArray()
	for para in text.split("\n"):
		var line := ""
		for word in para.split(" "):
			var trial := word if line == "" else line + " " + word
			if font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= width or line == "":
				line = trial
			else:
				out.append(line)
				line = word
		out.append(line)
	return out
