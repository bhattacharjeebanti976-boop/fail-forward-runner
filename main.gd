extends Node2D
## FAIL FORWARD
## Hack Club Harvest 2026 - theme: "Bounce Back"
## Every time you mess up, your oops turns into a bounce pad that stays for the
## rest of the level. Hold JUMP when you land on a pad for a SUPER boing.

const PlayerScript := preload("res://player.gd")
const SaveScript := preload("res://save.gd")

const T := 32
const COLS := 30
const ROWS := 17
const SW := 960
const SH := 544
const MAX_PADS := 14
const RATE := 22050
const MUSIC_RATE := 16000
const BOUNCE := -730.0
const SUPER_BOUNCE := -880.0
const INK := Color("2b1209")
const CREAM := Color("fff3cf")
const PALETTE := [Color("e8432b"), Color("f58a1f"), Color("f6c935"), Color("8cc63f"), Color("3fb6c9"), Color("a86ad6")]

# ops: ["spk", x, w]            floor spikes (row 14)
#      ["spy", x, y, w]         spikes standing at any row
#      ["cspk", x, y, w]        spikes hanging from a ceiling block
#      ["gap", x, w]            pit in the floor
#      ["block", x, y, w, h]    solid blocks
#      ["saw", x0, y0, x1, y1, speed]  patrolling saw blade (tile coords)
#      ["goal", x, y]           the basket
const LEVELS := [
	{"name": "Welcome to Oof", "chap": "OOF VALLEY", "hint": "Spikes! Walk right into them. Trust me.",
		"ops": [["spk", 9, 5], ["goal", 27, 14]]},
	{"name": "The Big Nothing", "hint": "Can't jump it? Fall in. Then boing back out.",
		"ops": [["gap", 11, 6], ["goal", 27, 14]]},
	{"name": "Stairs Are for Quitters", "hint": "Jumping is overrated. Fail upward!",
		"ops": [["spk", 6, 4], ["block", 10, 11, 4, 4], ["goal", 12, 10]]},
	{"name": "Long Way Down", "hint": "One pad? Cute. Make a few.",
		"ops": [["gap", 9, 9], ["goal", 27, 14]]},
	{"name": "Hold On Tight", "hint": "Hold JUMP when you land on a pad for a SUPER boing!",
		"ops": [["spk", 6, 4], ["block", 10, 8, 4, 7], ["goal", 12, 7]]},
	{"name": "Sawmill Shuffle", "chap": "SAWMILL WOODS", "hint": "Hop over the saws. Or don't. I'm a hint, not a cop.",
		"ops": [["saw", 7, 14, 13, 14, 95], ["saw", 16, 14, 23, 14, 130], ["goal", 27, 14]]},
	{"name": "Budget Cuts", "hint": "Only 2 pads allowed. Make your oopsies count!", "max": 2,
		"ops": [["spk", 7, 5], ["spk", 17, 5], ["goal", 27, 14]]},
	{"name": "Ladder of Oops", "hint": "Climb by messing up on every floor.",
		"ops": [["spk", 5, 2], ["block", 9, 11, 6, 1], ["spy", 13, 10, 2], ["block", 17, 8, 6, 1],
			["spy", 21, 7, 2], ["block", 25, 5, 5, 1], ["goal", 27, 4]]},
	{"name": "Pogo Party", "hint": "Three pits, zero chill. Keep bouncing!",
		"ops": [["gap", 5, 6], ["gap", 13, 6], ["gap", 21, 6], ["goal", 28, 14]]},
	{"name": "Saw Over Troubled Water", "hint": "Mind the saw. It does not mind you.",
		"ops": [["gap", 9, 8], ["saw", 10, 10, 15, 10, 120], ["goal", 27, 14]]},
	{"name": "Mind Your Head", "chap": "SPIKY CAVES", "hint": "Spiky ceiling! Holding JUMP is a baaad idea here.",
		"ops": [["gap", 8, 6], ["block", 7, 0, 8, 8], ["cspk", 7, 8, 8], ["goal", 27, 14]]},
	{"name": "Blinky Spikes", "hint": "They pop up. They pop down. Learn the rhythm!",
		"ops": [["tspk", 6, 3, 3.2, 0.0], ["tspk", 11, 3, 3.2, 0.8], ["tspk", 16, 3, 3.2, 1.6],
			["tspk", 21, 3, 3.2, 2.4], ["goal", 27, 14]]},
	{"name": "Duck and Cover", "hint": "Super boing + spiky ceiling = ouch. Regular boing only!",
		"ops": [["spk", 6, 3], ["block", 6, 0, 3, 7], ["cspk", 6, 7, 3], ["block", 9, 10, 4, 5], ["goal", 11, 9]]},
	{"name": "Spiky Staircase", "hint": "Three steps up. Each one costs you an oops.",
		"ops": [["spk", 4, 4], ["block", 8, 12, 8, 3], ["spy", 12, 11, 4], ["block", 16, 9, 8, 6],
			["spy", 20, 8, 4], ["block", 24, 6, 6, 9], ["goal", 27, 5]]},
	{"name": "The Big Oops", "hint": "Everything at once. Good luck. Bad luck. Whatever.",
		"ops": [["spk", 4, 4], ["saw", 10, 14, 14, 14, 100], ["gap", 16, 5], ["spk", 21, 4],
			["block", 25, 8, 5, 7], ["goal", 27, 7]]},
	{"name": "Moat Monsters", "chap": "CROW'S CASTLE", "hint": "Something is swimming in the moat. Something with teeth.",
		"ops": [["gap", 6, 6], ["gap", 17, 6], ["saw", 9, 12, 9, 15, 110], ["saw", 20, 12, 20, 15, 140], ["goal", 27, 14]]},
	{"name": "Tick Tock Tower", "hint": "Wait for the spikes to pop up. Then... use them.",
		"ops": [["tspk", 6, 4, 2.4, 0.0], ["block", 10, 8, 4, 7], ["goal", 12, 7]]},
	{"name": "Saw Slalom", "hint": "Three saws, one pumpkin. Wait for the gap, then go!",
		"ops": [["saw", 9, 11, 9, 14, 80], ["saw", 16, 11, 16, 14, 95], ["saw", 23, 11, 23, 14, 88],
			["goal", 27, 14]]},
	{"name": "Last Pad Standing", "hint": "Exactly 3 pads. Waste one and a spike comes back!", "max": 3,
		"ops": [["spk", 5, 5], ["spk", 13, 5], ["spk", 21, 5], ["goal", 28, 14]]},
	{"name": "Crowford's Castle", "hint": "The final nest. Everything you learned. Go go go!",
		"ops": [["gap", 4, 5], ["tspk", 11, 3, 2.4, 0.0], ["saw", 14, 14, 18, 14, 120], ["spk", 21, 4],
			["block", 25, 8, 5, 7], ["goal", 27, 7]]},
	{"name": "Windmill Welcome", "chap": "SCARECROW FARM", "hint": "Spinning saws on a farm? That's not in the brochure.",
		"ops": [["orb", 10, 12, 1.8, 2.2, 0.0], ["orb", 18, 12, 1.8, -2.4, 1.5], ["goal", 27, 14]]},
	{"name": "Pit Windmill", "hint": "Bounce out of the pit... between the spinning blades.",
		"ops": [["gap", 9, 8], ["orb", 13, 10, 2.2, 1.8, 0.0], ["goal", 27, 14]]},
	{"name": "Stan's Garden", "hint": "Stan really likes things that hurt. Watch your step.",
		"ops": [["tspk", 6, 3, 3.0, 0.0], ["orb", 12, 12, 1.8, 2.0, 0.0], ["tspk", 15, 3, 3.0, 1.5],
			["orb", 21, 12, 1.8, -2.0, 1.0], ["goal", 27, 14]]},
	{"name": "Hay Bale Heights", "hint": "Two steps up. One super boing, one regular boing.",
		"ops": [["spk", 6, 4], ["block", 10, 8, 8, 7], ["spy", 14, 7, 4], ["block", 18, 4, 12, 11], ["goal", 24, 3]]},
	{"name": "Stan's Showdown", "hint": "Stan's house. Stan's rules. Stan's saws.",
		"ops": [["gap", 3, 4], ["orb", 9, 12, 1.8, 2.2, 0.0], ["tspk", 12, 3, 2.6, 0.0], ["orb", 17, 12, 1.8, -2.2, 1.0],
			["spk", 21, 4], ["block", 25, 8, 5, 7], ["goal", 27, 7]]},
	{"name": "Blink Bridge", "chap": "PATCH OF DESTINY", "hint": "The bridge is shy. It disappears when you look at it.",
		"ops": [["gap", 8, 12], ["bblock", 9, 14, 2, 3.2, 0.0], ["bblock", 12, 14, 2, 3.2, 0.6],
			["bblock", 15, 14, 2, 3.2, 1.2], ["bblock", 18, 14, 2, 3.2, 1.8], ["goal", 27, 14]]},
	{"name": "Orbit Alley", "hint": "Saws on both sides of a pit. Pat did his homework.",
		"ops": [["orb", 7, 12, 1.8, 2.2, 0.0], ["gap", 11, 5], ["orb", 18, 12, 1.8, -2.4, 1.0],
			["orb", 24, 12, 1.8, 2.0, 2.0], ["goal", 28, 14]]},
	{"name": "Blinky Staircase", "hint": "Spiky stairs that blink. Wait for it... wait for it...",
		"ops": [["tspk", 4, 4, 2.6, 0.0, 14], ["block", 8, 12, 8, 3], ["tspk", 12, 4, 2.6, 0.9, 11],
			["block", 16, 9, 8, 6], ["tspk", 20, 4, 2.6, 1.7, 8], ["block", 24, 6, 6, 9], ["goal", 27, 5]]},
	{"name": "Last Stand", "hint": "Only 5 pads. Pat is almost out of patience.", "max": 5,
		"ops": [["gap", 3, 4], ["spk", 10, 4], ["orb", 19, 12, 1.8, 2.2, 0.0], ["spk", 22, 3],
			["block", 25, 8, 5, 7], ["goal", 27, 7]]},
	{"name": "Pumpkin Patch of Destiny", "hint": "The final level. Fail beautifully.",
		"ops": [["gap", 3, 7], ["bblock", 4, 14, 2, 3.0, 0.0], ["bblock", 7, 14, 2, 3.0, 1.0], ["tspk", 12, 3, 2.6, 0.0],
			["orb", 17, 12, 1.8, -2.2, 1.0], ["spk", 21, 4], ["block", 25, 8, 5, 7], ["goal", 27, 7]]},
]

# secret pumpkin for every level: pixel centre. Corner ones are "look behind you" secrets,
# the ones high above a pit or a platform need a bounce.
const MINIS := [
	Vector2(16, 422), Vector2(448, 348), Vector2(592, 422), Vector2(432, 348), Vector2(16, 422),
	Vector2(480, 422), Vector2(464, 422), Vector2(336, 294), Vector2(512, 348), Vector2(16, 422),
	Vector2(16, 422), Vector2(320, 422), Vector2(16, 422), Vector2(560, 230), Vector2(16, 422),
	Vector2(16, 422), Vector2(656, 422), Vector2(16, 422), Vector2(368, 422), Vector2(16, 422),
	Vector2(16, 422), Vector2(16, 422), Vector2(144, 422), Vector2(368, 198), Vector2(16, 422),
	Vector2(464, 348), Vector2(432, 348), Vector2(336, 326), Vector2(272, 422), Vector2(208, 348),
]

const HATS := [
	{"name": "NO HAT", "how": "Always yours", "kind": "none", "n": 0},
	{"name": "PARTY HAT", "how": "Oops 10 times", "kind": "deaths", "n": 10},
	{"name": "TOP HAT", "how": "Oops 40 times", "kind": "deaths", "n": 40},
	{"name": "PROPELLER", "how": "Bounce back 100 times", "kind": "bounces", "n": 100},
	{"name": "HALO", "how": "Oops 150 times", "kind": "deaths", "n": 150},
	{"name": "CROWN", "how": "Find every secret pumpkin", "kind": "minis", "n": 30},
]

const EPI_SPIKE := ["HUGGED A SPIKE", "SAT ON A SPIKE", "NOT SPIKE-PROOF", "POKED. DEAD.", "SPIKES 1, ME 0"]
const EPI_PIT := ["FELL FOR IT", "FORGOT TO JUMP", "THE FLOOR LEFT", "LOOKED DOWN. OOPS", "GRAVITY WINS"]
const EPI_SAW := ["MET A SAW", "SLICED. DICED.", "SAW IT COMING", "CUT SHORT", "SPLIT DECISION"]
const EPI_CEIL := ["BONKED THE ROOF", "TOO TALL TODAY", "HEAD FIRST"]
const EPI_ANY := ["BRAVE. NOT SMART.", "TRIED THEIR BEST", "BOUNCING SOMEWHERE", "THE LAST OOPS", "WORTH IT"]

const DEATH_WORDS := ["OOF!", "SPLAT!", "BONK!", "YEET!", "OUCH!", "WHOOPS!", "NOOO!", "SQUISH!"]
const BOUNCE_WORDS := ["BOING!", "SPROING!", "BOOP!", "BOUNCE!"]
const SUPER_WORDS := ["KA-BOING!!", "SUPER BOING!", "WHEEEE!"]
const WIN_WORDS := ["YAY!!", "BASKET!!", "NAILED IT!"]

var grid: Array = []
var spikes: Array = []
var cspikes: Array = []
var saws: Array = []
var tspikes: Array = []
var bblocks: Array = []
var disabled: Dictionary = {}
var pads: Array = []
var goal_cell := Vector2i(27, 14)
var spawn := Vector2.ZERO
var max_pads := MAX_PADS

var level_idx := 0
var state := "title"      # title | play | dead | clear | end
var timer := 0.0
var intro_t := 0.0
var deaths_total := 0
var deaths_level := 0
var pit_x := -1.0
var pad_cd := 0.0
var t_anim := 0.0
var sim_t := 0.0
var shake := 0.0
var muted := false

var solids: StaticBody2D
var player: CharacterBody2D
var fx: Node2D
var hud: Control
var cam: Camera2D
var parts: Array = []
var pops: Array = []
var leaves: Array = []
var clouds: Array = []
var font: Font = ThemeDB.fallback_font
var sb_sticker: StyleBoxFlat
var sb_key: StyleBoxFlat

var snd: Dictionary = {}
var sfx_players: Array = []
var sfx_i := 0
var music: AudioStreamPlayer

# cutscenes
var cs_id := ""
var cs_page := 0
var cs_t := 0.0
var cs_chars := 0.0
var cs_next := 0
var cs_blip := 0

# settings menu
const BAR_X0 := 430.0
const BAR_X1 := 680.0
var menu_open := false
const ITCH_URL := "https://latencybustersstudios.itch.io"
var splash_t := 0.0
var title_sel := 0
var title_last_mouse := Vector2(-1, -1)
var title_enter_held := false
var title_fade := 0.0
var title_mouse_down := true
var logo_tex: Texture2D
var sv: RefCounted
var ltime := 0.0
var timer_on := false
var bb_level := 0
var mini_active := false
var new_best := false
var last_epi := ""
var tombs: Array = []
var rings: Array = []
var toast_txt := ""
var toast_t := 0.0
var shake_amt := 1.0
var reset_armed := false
var clicked := false
var click_prev := false
var lv_sel := 0
var hat_sel := 0
var touch_mode := false
var touches: Dictionary = {}
const TB := {"left": Vector2(86, 466), "right": Vector2(214, 466), "jump": Vector2(874, 456)}
const TB_R := {"left": 54.0, "right": 54.0, "jump": 68.0, "pause": 26.0, "restart": 26.0}
const TPAUSE := Vector2(36, 232)
const TRETRY := Vector2(92, 232)
var menu_sel := 0
var menu_ctrl: Control
var dark_rect: ColorRect
var light_rect: ColorRect
var music_vol := 0.8
var sfx_vol := 0.8
var bright := 1.0
var rep_t := 0.0
var mouse_was_down := false
var last_mouse := Vector2.ZERO
var drag_snd_t := 0.0
var sb_sel: StyleBoxFlat
var sb_lock: StyleBoxFlat
var sb_bar: StyleBoxFlat


func _ready() -> void:
	randomize()
	if ResourceLoader.exists("res://LilitaOne.woff"):
		font = load("res://LilitaOne.woff")
	sb_sticker = _mk_box(CREAM, 14, 4)
	sb_key = _mk_box(Color("fffaf0"), 7, 3)
	sb_sel = _mk_box(Color("ffd23f"), 12, 3)
	sb_lock = _mk_box(Color("c9ad7c"), 12, 3)
	sb_bar = _mk_box(Color("e6d3a0"), 11, 3)
	process_mode = Node.PROCESS_MODE_ALWAYS
	sv = SaveScript.new(LEVELS.size())
	sv.load_file()
	PlayerScript.hat = int(sv.hat)
	_setup_input()
	_load_settings()
	_setup_buses()
	_make_audio()

	cam = Camera2D.new()
	cam.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	add_child(cam)

	player = PlayerScript.new()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.connect("jumped", _on_jumped)
	player.connect("landed", _on_landed)

	fx = Node2D.new()
	add_child(fx)
	fx.draw.connect(_draw_fx)

	var cl := CanvasLayer.new()
	add_child(cl)
	hud = Control.new()
	hud.size = Vector2(SW, SH)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(hud)
	hud.draw.connect(_draw_hud)

	# brightness overlays (above the game), then the settings menu on top of them
	var bl := CanvasLayer.new()
	bl.layer = 5
	add_child(bl)
	dark_rect = ColorRect.new()
	dark_rect.size = Vector2(SW, SH)
	dark_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bl.add_child(dark_rect)
	light_rect = ColorRect.new()
	light_rect.size = Vector2(SW, SH)
	light_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	light_rect.material = mat
	bl.add_child(light_rect)
	var ml := CanvasLayer.new()
	ml.layer = 10
	add_child(ml)
	menu_ctrl = Control.new()
	menu_ctrl.size = Vector2(SW, SH)
	menu_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_ctrl.visible = false
	ml.add_child(menu_ctrl)
	menu_ctrl.draw.connect(_draw_menu)
	_apply_settings()

	for i in 22:
		leaves.append({
			"p": Vector2(randf() * SW, randf() * SH),
			"v": Vector2(randf_range(-12, 12), randf_range(18, 46)),
			"rot": randf() * TAU, "spin": randf_range(-2, 2),
			"c": [Color("e8761e"), Color("d1342b"), Color("f2b632"), Color("9bbf2f")][randi() % 4],
		})
	for i in 5:
		clouds.append({"x": randf() * SW, "y": 40.0 + randf() * 150.0, "s": randf_range(0.7, 1.3), "v": randf_range(6, 16)})

	if ResourceLoader.exists("res://latency_logo.png"):
		logo_tex = load("res://latency_logo.png")
	load_level(0)
	state = "splash" if logo_tex != null else "title"
	splash_t = 0.0
	player.alive = false


func _mk_box(bg: Color, radius: int, border: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = INK
	s.shadow_color = Color(0.17, 0.07, 0.03, 0.35)
	s.shadow_offset = Vector2(3, 5)
	s.shadow_size = 1
	return s


# ---------------------------------------------------------------------- input
func _touch_hit(p: Vector2) -> String:
	for k in ["left", "right", "jump"]:
		if p.distance_to(TB[k]) <= float(TB_R[k]) + 14.0:
			return k
	if p.distance_to(TPAUSE) <= 34.0:
		return "pause"
	if p.distance_to(TRETRY) <= 34.0:
		return "restart"
	return ""


func _touch_down(idx: int, p: Vector2) -> void:
	if not (state == "play" or state == "dead" or state == "clear") or menu_open:
		return
	var act := _touch_hit(p)
	if act == "":
		return
	if act == "pause":
		_touch_release_all()
		_open_menu()
	elif act == "restart":
		state = "play"
		load_level(level_idx)
	else:
		touches[idx] = act
		Input.action_press(act)


func _touch_up(idx: int) -> void:
	if touches.has(idx):
		var act: String = touches[idx]
		touches.erase(idx)
		var still := false
		for v in touches.values():
			if v == act:
				still = true
		if not still:
			Input.action_release(act)


func _touch_release_all() -> void:
	for v in touches.values():
		Input.action_release(v)
	touches.clear()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_mode = true
		if event.pressed:
			_touch_down(event.index, event.position)
		else:
			_touch_up(event.index)
	elif event is InputEventScreenDrag:
		touch_mode = true
		if touches.has(event.index):
			var old: String = touches[event.index]
			var nw := _touch_hit(event.position)
			if nw != old and (nw == "left" or nw == "right" or nw == "jump"):
				_touch_up(event.index)
				touches[event.index] = nw
				Input.action_press(nw)


func _draw_touch() -> void:
	var held: Array = touches.values()
	for k in ["left", "right", "jump"]:
		var c: Vector2 = TB[k]
		var r: float = TB_R[k]
		var on := held.has(k)
		hud.draw_circle(c, r, Color(1, 0.96, 0.8, 0.5 if on else 0.28))
		hud.draw_arc(c, r, 0.0, TAU, 32, Color(INK, 0.7), 4.0)
		if k == "jump":
			var tw := font.get_string_size("JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x
			hud.draw_string(font, c + Vector2(-tw / 2.0, 10), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(INK, 0.85))
		else:
			var d := -1.0 if k == "left" else 1.0
			hud.draw_colored_polygon(PackedVector2Array([c + Vector2(d * 20, 0), c + Vector2(-d * 12, -20), c + Vector2(-d * 12, 20)]), Color(INK, 0.8))
	for pr in [[TPAUSE, "pause"], [TRETRY, "restart"]]:
		var pc: Vector2 = pr[0]
		hud.draw_circle(pc, 26.0, Color(1, 0.96, 0.8, 0.4))
		hud.draw_arc(pc, 26.0, 0.0, TAU, 24, Color(INK, 0.7), 3.0)
		if pr[1] == "pause":
			hud.draw_rect(Rect2(pc + Vector2(-9, -10), Vector2(6, 20)), Color(INK, 0.85))
			hud.draw_rect(Rect2(pc + Vector2(3, -10), Vector2(6, 20)), Color(INK, 0.85))
		else:
			hud.draw_arc(pc, 10.0, deg_to_rad(40), deg_to_rad(330), 14, Color(INK, 0.85), 3.5)
			hud.draw_colored_polygon(PackedVector2Array([pc + Vector2(10, -13), pc + Vector2(15, 0), pc + Vector2(3, -2)]), Color(INK, 0.85))


func _add_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(action, e)


func _setup_input() -> void:
	_add_action("left", [KEY_LEFT, KEY_A])
	_add_action("right", [KEY_RIGHT, KEY_D])
	_add_action("jump", [KEY_SPACE, KEY_UP, KEY_W, KEY_Z])
	_add_action("restart", [KEY_R])
	_add_action("mute", [KEY_M])
	_add_action("skip", [KEY_N])
	_add_action("pause", [KEY_ESCAPE, KEY_P])
	_add_action("menu_up", [KEY_UP, KEY_W])
	_add_action("menu_down", [KEY_DOWN, KEY_S])
	_add_action("menu_ok", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])
	_add_action("ui_back", [KEY_BACKSPACE])
	_add_action("fullscreen", [KEY_F])
	# gamepad
	_add_joy_button("jump", JOY_BUTTON_A)
	_add_joy_button("left", JOY_BUTTON_DPAD_LEFT)
	_add_joy_button("right", JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button("menu_up", JOY_BUTTON_DPAD_UP)
	_add_joy_button("menu_down", JOY_BUTTON_DPAD_DOWN)
	_add_joy_button("menu_ok", JOY_BUTTON_A)
	_add_joy_button("restart", JOY_BUTTON_Y)
	_add_joy_button("pause", JOY_BUTTON_START)
	_add_joy_button("skip", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button("ui_back", JOY_BUTTON_B)
	_add_joy_axis("left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis("right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis("menu_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis("menu_down", JOY_AXIS_LEFT_Y, 1.0)


func _add_joy_button(action: String, btn: int) -> void:
	var e := InputEventJoypadButton.new()
	e.button_index = btn
	InputMap.action_add_event(action, e)


func _add_joy_axis(action: String, axis: int, val: float) -> void:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = val
	InputMap.action_add_event(action, e)


# ---------------------------------------------------------------------- level
func load_level(i: int) -> void:
	level_idx = i
	var L: Dictionary = LEVELS[i]
	max_pads = L.get("max", MAX_PADS)
	grid = []
	for y in ROWS:
		var row: Array = []
		for x in COLS:
			row.append("#" if y >= 15 else ".")
		grid.append(row)
	saws = []
	tspikes = []
	bblocks = []
	var start := Vector2i(2, 14)
	for op in L["ops"]:
		match op[0]:
			"gap":
				for x in range(op[1], op[1] + op[2]):
					grid[15][x] = "."
					grid[16][x] = "."
			"spk":
				for x in range(op[1], op[1] + op[2]):
					grid[14][x] = "^"
			"spy":
				for x in range(op[1], op[1] + op[3]):
					grid[op[2]][x] = "^"
			"cspk":
				for x in range(op[1], op[1] + op[3]):
					grid[op[2]][x] = "v"
			"block":
				for y in range(op[2], op[2] + op[4]):
					for x in range(op[1], op[1] + op[3]):
						grid[y][x] = "#"
			"saw":
				saws.append({
					"a": Vector2((op[1] + 0.5) * T, (op[2] + 0.5) * T),
					"b": Vector2((op[3] + 0.5) * T, (op[4] + 0.5) * T),
					"spd": float(op[5]), "pos": Vector2.ZERO,
				})
			"tspk":
				var ty: int = op[5] if op.size() > 5 else 14
				for x in range(op[1], op[1] + op[2]):
					tspikes.append({"c": Vector2i(x, ty), "per": float(op[3]), "off": float(op[4])})
			"orb":
				saws.append({
					"c": Vector2((op[1] + 0.5) * T, (op[2] + 0.5) * T), "r": float(op[3]) * T,
					"w": float(op[4]), "ph": float(op[5]), "pos": Vector2.ZERO,
				})
			"bblock":
				bblocks.append({"x": op[1], "y": op[2], "w": op[3], "per": float(op[4]), "off": float(op[5]), "on": true, "shape": null})
			"goal":
				goal_cell = Vector2i(op[1], op[2])
	spikes = []
	cspikes = []
	for y in ROWS:
		for x in COLS:
			if grid[y][x] == "^":
				spikes.append(Vector2i(x, y))
			elif grid[y][x] == "v":
				cspikes.append(Vector2i(x, y))
	pads.clear()
	disabled.clear()
	parts.clear()
	pops.clear()
	deaths_level = 0
	ltime = 0.0
	timer_on = false
	bb_level = 0
	new_best = false
	tombs.clear()
	rings.clear()
	mini_active = not bool(sv.minis[i])
	intro_t = 1.9
	sim_t = 0.0
	_update_saws()
	spawn = Vector2(start.x * T + 16, (start.y + 1) * T - 13)
	_build_solids()
	_make_bblocks()
	_respawn()


func _add_rect(a: Array) -> void:
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(a[1] * T, a[3] * T)
	cs.shape = sh
	cs.position = Vector2(a[0] * T + a[1] * T / 2.0, a[2] * T + a[3] * T / 2.0)
	solids.add_child(cs)


func _build_solids() -> void:
	if solids != null:
		remove_child(solids)
		solids.queue_free()
	solids = StaticBody2D.new()
	add_child(solids)
	var open: Dictionary = {}
	for y in ROWS:
		var runs: Array = []
		var x := 0
		while x < COLS:
			if grid[y][x] == "#":
				var s := x
				while x < COLS and grid[y][x] == "#":
					x += 1
				runs.append([s, x - s])
			else:
				x += 1
		var nxt: Dictionary = {}
		for r in runs:
			var key := "%d_%d" % [r[0], r[1]]
			if open.has(key):
				nxt[key] = open[key]
				nxt[key][3] += 1
			else:
				nxt[key] = [r[0], r[1], y, 1]
		for key in open:
			if not nxt.has(key):
				_add_rect(open[key])
		open = nxt
	for key in open:
		_add_rect(open[key])
	_add_rect([-1, 1, -10, 40])
	_add_rect([COLS, 1, -10, 40])


func _respawn() -> void:
	player.position = spawn
	player.velocity = Vector2.ZERO
	player.visible = true
	player.squash = Vector2.ONE
	player.bouncing = false
	player.buf = 0.0
	player.alive = (state == "play" or state == "dead")
	pit_x = -1.0
	pad_cd = 0.0


func _update_saws() -> void:
	for s in saws:
		if s.has("c"):
			var ang: float = float(s["ph"]) + sim_t * float(s["w"])
			var oc: Vector2 = s["c"]
			s["pos"] = oc + Vector2(cos(ang), sin(ang)) * float(s["r"])
			continue
		var a: Vector2 = s["a"]
		var b: Vector2 = s["b"]
		var d := maxf(a.distance_to(b), 1.0)
		var m := fposmod(sim_t * float(s["spd"]), 2.0 * d)
		var f := m / d if m <= d else (2.0 * d - m) / d
		s["pos"] = a.lerp(b, f)


# ----------------------------------------------------------------- game logic
func _process(delta: float) -> void:
	t_anim += delta
	for p in pads:
		p["anim"] = maxf(0.0, p["anim"] - delta * 3.0)
		p["born"] = maxf(0.0, p["born"] - delta * 3.5)
	for i in range(parts.size() - 1, -1, -1):
		var q: Dictionary = parts[i]
		q["l"] -= delta
		if q["l"] <= 0.0:
			parts.remove_at(i)
			continue
		q["v"].y += 700.0 * delta
		q["p"] += q["v"] * delta
	for i in range(pops.size() - 1, -1, -1):
		var q: Dictionary = pops[i]
		q["age"] += delta
		if q["age"] > 0.95:
			pops.remove_at(i)
			continue
		q["p"].y -= 38.0 * delta
	for l in leaves:
		l["p"] += l["v"] * delta
		l["p"].x += sin(t_anim * 1.6 + l["rot"]) * 14.0 * delta
		l["rot"] += l["spin"] * delta
		if l["p"].y > SH + 10:
			l["p"] = Vector2(randf() * SW, -10.0)
	for c in clouds:
		c["x"] += c["v"] * delta
		if c["x"] > SW + 120:
			c["x"] = -120.0
	if state == "play" or state == "dead" or state == "clear":
		intro_t = maxf(0.0, intro_t - delta)
	for i in range(rings.size() - 1, -1, -1):
		rings[i]["age"] += delta
		if rings[i]["age"] > 0.5:
			rings.remove_at(i)
	for i in range(tombs.size() - 1, -1, -1):
		tombs[i]["age"] += delta
		if tombs[i]["age"] > 2.6:
			tombs.remove_at(i)
	toast_t = maxf(0.0, toast_t - delta)
	var down_now := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	clicked = down_now and not click_prev
	click_prev = down_now
	shake = move_toward(shake, 0.0, 34.0 * delta)
	cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake * shake_amt
	queue_redraw()
	fx.queue_redraw()
	hud.queue_redraw()

	if Input.is_action_just_pressed("mute"):
		muted = not muted
		AudioServer.set_bus_mute(0, muted)

	if Input.is_action_just_pressed("fullscreen"):
		var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fs else DisplayServer.WINDOW_MODE_FULLSCREEN)
	if not touches.is_empty() and not (state == "play" or state == "dead" or state == "clear"):
		_touch_release_all()
	if Input.is_action_just_pressed("pause") and not menu_open and state != "levels" and state != "hats" and state != "splash":
		_open_menu()
		return
	if menu_open:
		_menu_input(delta)
		menu_ctrl.queue_redraw()
		return

	match state:
		"splash":
			splash_t += delta
			var skip := Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ENTER) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
			if splash_t > SPLASH_END or (skip and splash_t > 0.5):
				state = "title"
				title_fade = 1.0
				title_mouse_down = true
		"title":
			title_fade = maxf(0.0, title_fade - delta * 1.2)
			_title_input()
		"levels":
			_levels_input()
		"hats":
			_hats_input()
		"end":
			if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("menu_ok") or clicked:
				_to_title()
		"cutscene":
			_cutscene_update(delta)
		"play", "dead":
			if Input.is_action_just_pressed("restart"):
				state = "play"
				load_level(level_idx)
			elif Input.is_action_just_pressed("skip"):
				_next_level()


func _physics_process(delta: float) -> void:
	if menu_open:
		return
	sim_t += delta
	_update_saws()
	_update_bblocks()
	pad_cd = maxf(0.0, pad_cd - delta)
	match state:
		"play":
			if timer_on:
				ltime += delta
			_check_play()
		"dead":
			if timer_on:
				ltime += delta
			timer -= delta
			if timer <= 0.0:
				state = "play"
				_respawn()
		"clear":
			timer -= delta
			if timer <= 0.0:
				_next_level()


func _check_play() -> void:
	var pr := Rect2(player.position - Vector2(10, 13), Vector2(20, 26))
	if not timer_on and (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("jump")):
		timer_on = true
	if mini_active and player.position.distance_to(MINIS[level_idx]) < 24.0:
		_collect_mini()

	if player.position.y < 490.0:
		pit_x = -1.0
	elif pit_x < 0.0 and player.position.y > 499.0:
		pit_x = player.position.x
	if player.position.y > ROWS * T + 30:
		_die(false, Vector2i.ZERO, "pit")
		return

	var gr := Rect2(goal_cell.x * T + 2, goal_cell.y * T + 2, 28, 30)
	if pr.intersects(gr):
		_clear()
		return

	if pad_cd <= 0.0 and player.velocity.y > -120.0:
		for p in pads:
			var c: Vector2i = p["cell"]
			var r := Rect2(c.x * T - 6, c.y * T + 10, 44, 22)
			if pr.intersects(r):
				_bounce(p)
				return

	for c in spikes:
		if disabled.has(c):
			continue
		if pr.intersects(Rect2(c.x * T + 6, c.y * T + 16, 20, 16)):
			_die(true, c, "spike")
			return
	for ts in tspikes:
		var tc: Vector2i = ts["c"]
		if disabled.has(tc):
			continue
		if _tspike_f(ts) >= 0.7 and pr.intersects(Rect2(tc.x * T + 6, tc.y * T + 16, 20, 16)):
			_die(true, tc, "spike")
			return
	for c in cspikes:
		if pr.intersects(Rect2(c.x * T + 6, c.y * T, 20, 16)):
			_die(false, Vector2i.ZERO, "ceil")
			return
	for s in saws:
		var sp: Vector2 = s["pos"]
		var cx := clampf(sp.x, pr.position.x, pr.end.x)
		var cy := clampf(sp.y, pr.position.y, pr.end.y)
		if Vector2(cx, cy).distance_to(sp) < 12.5:
			_die(false, Vector2i.ZERO, "saw")
			return


func _bb_on(b: Dictionary) -> bool:
	return fposmod(sim_t + float(b["off"]), float(b["per"])) / float(b["per"]) < 0.62


func _make_bblocks() -> void:
	for b in bblocks:
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = Vector2(int(b["w"]) * T, T)
		cs.shape = sh
		cs.position = Vector2(int(b["x"]) * T + int(b["w"]) * T / 2.0, int(b["y"]) * T + T / 2.0)
		solids.add_child(cs)
		b["shape"] = cs
		b["on"] = _bb_on(b)
		cs.disabled = not b["on"]


func _update_bblocks() -> void:
	for b in bblocks:
		var on := _bb_on(b)
		if on != b["on"]:
			b["on"] = on
			(b["shape"] as CollisionShape2D).set_deferred("disabled", not on)


func _tspike_f(ts: Dictionary) -> float:
	var per: float = ts["per"]
	var ph := fposmod(sim_t + float(ts["off"]), per) / per
	if ph < 0.06:
		return ph / 0.06
	if ph < 0.44:
		return 1.0
	if ph < 0.5:
		return (0.5 - ph) / 0.06
	if ph >= 0.9:
		return 0.28
	return 0.0


func _bounce(p: Dictionary) -> void:
	var sup: bool = Input.is_action_pressed("jump") or player.buf > 0.0
	player.velocity.y = SUPER_BOUNCE if sup else BOUNCE
	player.bouncing = true
	player.coyote = 0.0
	player.squash = Vector2(0.65, 1.45)
	p["anim"] = 1.0
	pad_cd = 0.15
	_play("super" if sup else "bounce")
	var pc: Vector2i = p["cell"]
	var at := Vector2(pc.x * T + 16, pc.y * T + 28)
	_popup(SUPER_WORDS.pick_random() if sup else BOUNCE_WORDS.pick_random(), at + Vector2(0, -26),
		Color("b6ee3c") if sup else Color("f6e05a"), 40 if sup else 30)
	_burst(player.position + Vector2(0, 12), Color("b6dc3c"), 16 if sup else 8, 180.0)
	_burst(player.position + Vector2(0, 12), Color("fff6a0"), 10 if sup else 5, 240.0)
	rings.append({"p": Vector2(pc.x * T + 16, pc.y * T + 28), "age": 0.0, "sup": sup})
	shake = 3.0 if sup else 1.2
	bb_level += 1
	sv.bounces += 1
	if sv.bounces % 5 == 0:
		_check_unlocks()


func _die(on_spike: bool, cell: Vector2i, cause: String = "") -> void:
	if state != "play":
		return
	state = "dead"
	timer = 0.7
	player.alive = false
	player.visible = false
	deaths_total += 1
	deaths_level += 1
	sv.deaths += 1
	sv.ldeaths[level_idx] += 1
	last_epi = _pick_epitaph(cause)
	var at := Vector2(player.position.x, minf(player.position.y, SH - 40.0))
	_burst(at, Color("f58a1f"), 26, 260.0)
	_burst(at, Color("5f9a2a"), 8, 200.0)
	_popup(DEATH_WORDS.pick_random(), at + Vector2(0, -24), Color("ff6b4a"), 40)
	shake = 6.0
	_play("death")
	if on_spike:
		_add_pad(cell, true)
	else:
		var px := pit_x if pit_x >= 0.0 else player.position.x
		_drop_pad(px, minf(player.position.y, SH - 1.0))
	_check_unlocks()
	sv.save_file()


func _pick_epitaph(cause: String) -> String:
	var pool: Array = EPI_ANY
	if randf() > 0.25:
		match cause:
			"spike":
				pool = EPI_SPIKE
			"pit":
				pool = EPI_PIT
			"saw":
				pool = EPI_SAW
			"ceil":
				pool = EPI_CEIL
	return pool.pick_random()


func _collect_mini() -> void:
	mini_active = false
	sv.minis[level_idx] = true
	var mp: Vector2 = MINIS[level_idx]
	_play("coin")
	_popup("SECRET PUMPKIN!", mp + Vector2(0, -34), Color("ffd23f"), 36)
	_burst(mp, Color("ffd23f"), 18, 240.0)
	_burst(mp, Color("fff6dc"), 8, 160.0)
	_toast("SECRET PUMPKINS  %d / %d" % [sv.count_minis(), LEVELS.size()])
	_check_unlocks()
	sv.save_file()


func _toast(txt: String) -> void:
	toast_txt = txt
	toast_t = 3.2


func _hat_unlocked(i: int) -> bool:
	var h: Dictionary = HATS[i]
	match String(h["kind"]):
		"deaths":
			return sv.deaths >= int(h["n"])
		"bounces":
			return sv.bounces >= int(h["n"])
		"minis":
			return sv.count_minis() >= LEVELS.size()
	return true


func _hat_progress(i: int) -> String:
	var h: Dictionary = HATS[i]
	match String(h["kind"]):
		"deaths":
			return "%d / %d" % [mini(sv.deaths, int(h["n"])), int(h["n"])]
		"bounces":
			return "%d / %d" % [mini(sv.bounces, int(h["n"])), int(h["n"])]
		"minis":
			return "%d / %d" % [sv.count_minis(), LEVELS.size()]
	return ""


func _check_unlocks() -> void:
	for i in range(1, HATS.size()):
		if _hat_unlocked(i) and (int(sv.seen) & (1 << i)) == 0:
			sv.seen = int(sv.seen) | (1 << i)
			_toast("NEW HAT UNLOCKED: %s!  (see HATS)" % HATS[i]["name"])
			_play("unlock")


## Finds the floor under (px, py) and puts a pad there (neighbouring columns if taken).
func _drop_pad(px: float, py: float) -> void:
	var base := int(clampf(px, 0.0, COLS * T - 1.0) / T)
	var row0 := clampi(int(py / T), 0, ROWS - 1)
	for o in [0, 1, -1, 2, -2, 3, -3, 4, -4]:
		var cx := clampi(base + o, 0, COLS - 1)
		var r := row0
		if grid[r][cx] == "#":
			continue
		while r + 1 < ROWS and grid[r + 1][cx] != "#":
			r += 1
		var c := Vector2i(cx, r)
		if _has_pad(c):
			continue
		_add_pad(c, grid[r][cx] == "^")
		return


func _has_pad(c: Vector2i) -> bool:
	for p in pads:
		if p["cell"] == c:
			return true
	return false


func _add_pad(c: Vector2i, on_spike: bool) -> void:
	while pads.size() >= max_pads:
		var old: Dictionary = pads.pop_front()
		disabled.erase(old["cell"])
	if on_spike:
		disabled[c] = true
	pads.append({"cell": c, "anim": 0.0, "born": 1.0, "epi": last_epi})
	if last_epi != "":
		tombs.append({"p": Vector2(c.x * T + 16, c.y * T - 6), "t": last_epi, "age": 0.0})
	last_epi = ""
	_play("pop")


func _clear() -> void:
	state = "clear"
	timer = 1.1
	player.alive = false
	player.velocity = Vector2.ZERO
	_play("win")
	var prev: float = sv.best[level_idx]
	new_best = prev < 0.0 or ltime < prev
	if new_best:
		sv.best[level_idx] = ltime
	sv.done[level_idx] = true
	sv.reach = maxi(int(sv.reach), mini(level_idx + 1, LEVELS.size() - 1))
	sv.save_file()
	var gp := Vector2(goal_cell.x * T + 16, goal_cell.y * T + 10)
	_popup(WIN_WORDS.pick_random(), gp + Vector2(0, -40), Color("ffd23f"), 48)
	if new_best and prev >= 0.0:
		_popup("NEW BEST! " + _fmt_time(ltime), gp + Vector2(-70, -96), Color("b6ee3c"), 30)
	for col in [Color("f2b632"), Color("d1342b"), Color("9bbf2f"), Color("fff6dc")]:
		_burst(gp, col, 10, 280.0)


func _fmt_time(t: float) -> String:
	if t < 0.0:
		return "--"
	if t >= 60.0:
		return "%d:%04.1f" % [int(t / 60.0), fmod(t, 60.0)]
	return "%.1fs" % t


func _fit(text: String, size: int, maxw: float) -> String:
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= maxw:
		return text
	while text.length() > 1 and font.get_string_size(text + "..", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > maxw:
		text = text.substr(0, text.length() - 1)
	return text + ".."


func _to_title() -> void:
	state = "title"
	title_mouse_down = true
	load_level(0)
	intro_t = 0.0
	player.alive = false
	player.visible = false


func _next_level() -> void:
	sv.reach = maxi(int(sv.reach), mini(level_idx + 1, LEVELS.size() - 1))
	if CUTSCENE_AFTER.has(level_idx):
		_start_cutscene(CUTSCENE_AFTER[level_idx], level_idx + 1 if level_idx + 1 < LEVELS.size() else -1)
		return
	if level_idx + 1 >= LEVELS.size():
		_show_end()
		return
	state = "play"
	load_level(level_idx + 1)


func _show_end() -> void:
	state = "end"
	player.alive = false
	player.visible = false
	for i in 60:
		_burst(Vector2(randf() * SW, randf() * 200.0), PALETTE[i % PALETTE.size()], 1, 120.0)


func _burst(pos: Vector2, col: Color, n: int, speed: float) -> void:
	for i in n:
		var a := randf() * TAU
		parts.append({
			"p": pos, "v": Vector2(cos(a), sin(a)) * randf_range(0.3, 1.0) * speed + Vector2(0, -80),
			"l": randf_range(0.4, 0.9), "c": col, "s": randf_range(3, 7),
		})


func _popup(text: String, pos: Vector2, col: Color, size: int) -> void:
	pops.append({"t": text, "p": pos, "c": col, "s": size, "age": 0.0, "rot": randf_range(-0.2, 0.2)})


func _on_jumped() -> void:
	_play("jump")
	_burst(player.position + Vector2(0, 13), Color(1.0, 0.95, 0.8), 3, 60.0)


func _on_landed() -> void:
	_play("land")
	_burst(player.position + Vector2(0, 13), Color(1.0, 0.95, 0.8), 5, 80.0)


# -------------------------------------------------------------- draw helpers
func _poly(c: CanvasItem, pts: PackedVector2Array, fill: Color, w: float = 3.0) -> void:
	c.draw_colored_polygon(pts, fill)
	var o := pts.duplicate()
	o.append(pts[0])
	c.draw_polyline(o, INK, w, true)


func _disc(c: CanvasItem, p: Vector2, r: float, fill: Color, w: float = 2.5) -> void:
	c.draw_circle(p, r + w, INK)
	c.draw_circle(p, r, fill)


func _txt(c: CanvasItem, s: String, pos: Vector2, size: int, col: Color, ol: int = 8) -> void:
	c.draw_string_outline(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ol, INK)
	c.draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _txtc(c: CanvasItem, s: String, cx: float, y: float, size: int, col: Color, ol: int = 8) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	_txt(c, s, Vector2(cx - w / 2.0, y), size, col, ol)


func _sticker(c: CanvasItem, center: Vector2, size: Vector2, rot: float = 0.0, box: StyleBoxFlat = null) -> void:
	c.draw_set_transform(center, rot, Vector2.ONE)
	c.draw_style_box(box if box != null else sb_sticker, Rect2(-size / 2.0, size))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sticker_text(c: CanvasItem, s: String, center: Vector2, size: int, rot: float = 0.0, col: Color = INK, pad: float = 22.0) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	_sticker(c, center, Vector2(w + pad * 2.0, size + 18.0), rot)
	c.draw_set_transform(center, rot, Vector2.ONE)
	c.draw_string(font, Vector2(-w / 2.0, size * 0.36), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _wobble_word(c: CanvasItem, word: String, cx: float, y: float, size: int, phase: float) -> void:
	var widths: Array = []
	var total := 0.0
	for ch in word:
		var w := font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		widths.append(w)
		total += w
	var x := cx - total / 2.0
	for i in word.length():
		var w: float = widths[i]
		var dy := sin(t_anim * 3.0 + i * 0.75 + phase) * 7.0
		var rot := sin(t_anim * 2.0 + i * 1.3 + phase) * 0.09
		c.draw_set_transform(Vector2(x + w / 2.0, y + dy + 5.0), rot, Vector2.ONE)
		c.draw_string_outline(font, Vector2(-w / 2.0 + 4, 6), word[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size, 22, Color(0, 0, 0, 0.25))
		c.draw_set_transform(Vector2(x + w / 2.0, y + dy), rot, Vector2.ONE)
		c.draw_string_outline(font, Vector2(-w / 2.0, 0), word[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size, 18, INK)
		c.draw_string(font, Vector2(-w / 2.0, 0), word[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size, PALETTE[(i + int(phase)) % PALETTE.size()])
		x += w
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _keycap(c: CanvasItem, label: String, x: float, y: float) -> float:
	var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 18.0
	c.draw_style_box(sb_key, Rect2(x, y, w, 32))
	c.draw_string(font, Vector2(x + 9, y + 24), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK)
	return w


func _draw_pad(c: CanvasItem, cx: float, base_y: float, a: float, born: float, sc: float = 1.0) -> void:
	var k := 1.0 - born * 0.85
	var body := Vector2(sc * k, sc * (0.5 + 0.5 * a) * k)
	c.draw_set_transform(Vector2(cx, base_y), 0.0, body)
	c.draw_circle(Vector2(0, -15), 18.5, INK)
	c.draw_circle(Vector2(0, -15), 16.0, Color("9bd02f"))
	c.draw_arc(Vector2(0, -15), 10, deg_to_rad(100), deg_to_rad(260), 10, Color("6aa01c"), 2.5)
	c.draw_arc(Vector2(0, -15), 10, deg_to_rad(-80), deg_to_rad(80), 10, Color("6aa01c"), 2.5)
	c.draw_set_transform(Vector2(cx, base_y), 0.0, Vector2(sc, sc))
	var ey := -9.0 - 7.0 * a
	for sx in [-6.0, 6.0]:
		c.draw_line(Vector2(sx - 3, ey - 3), Vector2(sx + 3, ey + 3), INK, 2.4)
		c.draw_line(Vector2(sx + 3, ey - 3), Vector2(sx - 3, ey + 3), INK, 2.4)
	c.draw_circle(Vector2(0, ey + 6), 2.6, INK)
	c.draw_circle(Vector2(0, ey + 7), 1.4, Color("ff7a8a"))
	var pulse := 0.5 + 0.5 * sin(t_anim * 5.0)
	var ay := -27.0 - pulse * 4.0 - a * 6.0
	_poly(c, PackedVector2Array([Vector2(-5, ay), Vector2(5, ay), Vector2(0, ay - 8)]), Color("fff3a0"), 2.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_saw(c: CanvasItem, p: Vector2, spin: float) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := spin + i * TAU / 20.0
		var r := 17.0 if i % 2 == 0 else 12.0
		pts.append(p + Vector2(cos(a), sin(a)) * r)
	_poly(c, pts, Color("d7dde3"), 3.0)
	_disc(c, p, 6.5, Color("8a95a1"), 2.5)
	c.draw_circle(p, 2.2, INK)


# --------------------------------------------------------------- world drawing
func _draw() -> void:
	var top := Color("ffe39a")
	var bot := Color("f6a55a")
	for y in ROWS:
		draw_rect(Rect2(0, y * T, SW, T + 1), top.lerp(bot, float(y) / ROWS))

	# smiling sun
	var sun := Vector2(790, 105)
	for i in 12:
		var a := t_anim * 0.25 + i * TAU / 12.0
		_poly(self, PackedVector2Array([sun + Vector2(cos(a - 0.1), sin(a - 0.1)) * 58, sun + Vector2(cos(a), sin(a)) * 82, sun + Vector2(cos(a + 0.1), sin(a + 0.1)) * 58]), Color("ffd23f"), 3.0)
	_disc(self, sun, 48, Color("ffe66b"), 3.5)
	draw_circle(sun + Vector2(-15, -6), 4.5, INK)
	draw_circle(sun + Vector2(15, -6), 4.5, INK)
	draw_arc(sun + Vector2(0, 4), 18, deg_to_rad(20), deg_to_rad(160), 10, INK, 3.5)
	draw_circle(sun + Vector2(-27, 8), 6, Color(1, 0.55, 0.45, 0.6))
	draw_circle(sun + Vector2(27, 8), 6, Color(1, 0.55, 0.45, 0.6))

	for c in clouds:
		var cp := Vector2(c["x"], c["y"])
		var s: float = c["s"]
		for o in [Vector2(-26, 6), Vector2(0, -6), Vector2(26, 6), Vector2(0, 8)]:
			draw_circle(cp + o * s, 22 * s + 3.0, INK)
		for o in [Vector2(-26, 6), Vector2(0, -6), Vector2(26, 6), Vector2(0, 8)]:
			draw_circle(cp + o * s, 22 * s, Color.WHITE)

	for layer in 2:
		var pts := PackedVector2Array()
		for x in range(0, SW + 41, 40):
			pts.append(Vector2(x, 370 + layer * 55 + sin(x * 0.011 + layer * 2.0) * 30))
		pts.append(Vector2(SW, SH))
		pts.append(Vector2(0, SH))
		draw_colored_polygon(pts, Color(0.86, 0.45, 0.2, 0.25 + layer * 0.14))

	# tiles
	for y in ROWS:
		for x in COLS:
			if grid[y][x] != "#":
				continue
			var r := Rect2(x * T, y * T, T, T)
			draw_rect(r, Color("9a5128"))
			draw_rect(Rect2(r.position + Vector2(0, 14), Vector2(T, T - 14)), Color("8c4822"))
			if (x * 7 + y * 3) % 4 == 0:
				draw_circle(r.position + Vector2(11, 20), 3.2, Color("6c3416"))
			if (x * 5 + y * 11) % 5 == 0:
				draw_circle(r.position + Vector2(23, 11), 2.4, Color("b86a37"))
	for y in ROWS:
		for x in COLS:
			if grid[y][x] != "#":
				continue
			var x0 := float(x * T)
			var y0 := float(y * T)
			var up: bool = y == 0 or grid[y - 1][x] != "#"
			if up:
				draw_line(Vector2(x0, y0), Vector2(x0 + T, y0), INK, 5.0)
			if y > 0 and y < ROWS - 1 and grid[y + 1][x] != "#":
				draw_line(Vector2(x0, y0 + T), Vector2(x0 + T, y0 + T), INK, 5.0)
			if x == 0 or grid[y][x - 1] != "#":
				draw_line(Vector2(x0, y0), Vector2(x0, y0 + T), INK, 5.0)
			if x == COLS - 1 or grid[y][x + 1] != "#":
				draw_line(Vector2(x0 + T, y0), Vector2(x0 + T, y0 + T), INK, 5.0)
	for y in ROWS:
		for x in COLS:
			if grid[y][x] == "#" and (y == 0 or grid[y - 1][x] != "#"):
				for k in 3:
					var bc := Vector2(x * T + 5.0 + k * 11.0, y * T + 4.0)
					_disc(self, bc, 5.5, Color("f58a1f") if (x + k) % 2 == 0 else Color("f6a62a"), 2.0)
				draw_rect(Rect2(x * T, y * T + 2, T, 5), Color("f58a1f"))

	# saw rails
	for s in saws:
		if s.has("c"):
			var oc: Vector2 = s["c"]
			draw_arc(oc, float(s["r"]), 0.0, TAU, 56, Color(0.17, 0.07, 0.03, 0.55), 5.0)
			draw_arc(oc, float(s["r"]), 0.0, TAU, 56, Color(1, 0.95, 0.8, 0.55), 2.0)
			draw_circle(oc, 5, INK)
			continue
		var a: Vector2 = s["a"]
		var b: Vector2 = s["b"]
		draw_line(a, b, Color(0.17, 0.07, 0.03, 0.55), 5.0)
		draw_line(a, b, Color(1, 0.95, 0.8, 0.55), 2.0)
		draw_circle(a, 4, INK)
		draw_circle(b, 4, INK)

	# spikes
	for c in spikes:
		if disabled.has(c):
			continue
		var x0 := float(c.x * T)
		var y0 := float((c.y + 1) * T)
		_poly(self, PackedVector2Array([Vector2(x0 + 1, y0), Vector2(x0 + 9, y0 - 20), Vector2(x0 + 17, y0)]), Color("e8432b"))
		_poly(self, PackedVector2Array([Vector2(x0 + 15, y0), Vector2(x0 + 23, y0 - 20), Vector2(x0 + 31, y0)]), Color("c9301f"))
	for c in cspikes:
		var x0 := float(c.x * T)
		var y0 := float(c.y * T)
		_poly(self, PackedVector2Array([Vector2(x0 + 1, y0), Vector2(x0 + 9, y0 + 20), Vector2(x0 + 17, y0)]), Color("e8432b"))
		_poly(self, PackedVector2Array([Vector2(x0 + 15, y0), Vector2(x0 + 23, y0 + 20), Vector2(x0 + 31, y0)]), Color("c9301f"))

	for ts in tspikes:
		var tc: Vector2i = ts["c"]
		if disabled.has(tc):
			continue
		var f := _tspike_f(ts)
		var x0 := float(tc.x * T)
		var y0 := float((tc.y + 1) * T)
		draw_rect(Rect2(x0 + 2, y0 - 5, 28, 5), INK)
		draw_rect(Rect2(x0 + 4, y0 - 4, 24, 2), Color("8a7a6a"))
		if f > 0.02:
			var hgt := 20.0 * f
			var col_a := Color("e8432b") if f >= 0.7 else Color("f6a62a")
			_poly(self, PackedVector2Array([Vector2(x0 + 3, y0 - 4), Vector2(x0 + 10, y0 - 4 - hgt), Vector2(x0 + 17, y0 - 4)]), col_a, 2.5)
			_poly(self, PackedVector2Array([Vector2(x0 + 15, y0 - 4), Vector2(x0 + 22, y0 - 4 - hgt), Vector2(x0 + 29, y0 - 4)]), col_a, 2.5)

	# blinking platforms
	for b in bblocks:
		var ph := fposmod(sim_t + float(b["off"]), float(b["per"])) / float(b["per"])
		var on := ph < 0.62
		var warn := ph >= 0.5 and ph < 0.62
		for k in int(b["w"]):
			var r := Rect2((int(b["x"]) + k) * T, int(b["y"]) * T, T, T)
			if on:
				var a := 1.0
				if warn and fposmod(t_anim * 10.0, 1.0) < 0.5:
					a = 0.35
				draw_rect(r, Color(0.62, 0.89, 0.82, a))
				draw_rect(r.grow(-6), Color(0.48, 0.78, 0.7, a), false, 3.0)
				draw_line(r.position + Vector2(8, 8), r.position + Vector2(24, 24), Color(1, 1, 1, 0.6 * a), 3.0)
				draw_rect(r, Color(INK, a), false, 4.0)
			else:
				draw_rect(r.grow(-3), Color(INK, 0.28), false, 2.0)

	# pads (your oopsies)
	for p in pads:
		var c: Vector2i = p["cell"]
		_draw_pad(self, c.x * T + 16.0, (c.y + 1) * T - 1.0, p["anim"], p["born"])

	# saws
	for s in saws:
		_draw_saw(self, s["pos"], sim_t * 9.0)

	# the goal basket
	var gx := goal_cell.x * T + 16.0
	var gy := goal_cell.y * T + 32.0 + sin(t_anim * 3.0) * 3.0
	draw_circle(Vector2(gx, gy - 14), 26 + sin(t_anim * 4.0) * 2.0, Color(1, 0.95, 0.6, 0.4))
	_disc(self, Vector2(gx - 8, gy - 19), 6.5, Color("e8432b"), 2.2)
	_disc(self, Vector2(gx + 3, gy - 23), 7.5, Color("f58a1f"), 2.2)
	_disc(self, Vector2(gx + 11, gy - 18), 6.5, Color("8cc63f"), 2.2)
	_poly(self, PackedVector2Array([Vector2(gx - 16, gy - 16), Vector2(gx + 16, gy - 16), Vector2(gx + 11, gy), Vector2(gx - 11, gy)]), Color("b8702f"), 3.5)
	draw_line(Vector2(gx - 14, gy - 10), Vector2(gx + 14, gy - 10), Color("7a4519"), 2.5)
	draw_line(Vector2(gx - 12, gy - 4), Vector2(gx + 12, gy - 4), Color("7a4519"), 2.5)
	for i in 3:
		var sa := t_anim * 2.0 + i * 2.1
		var sp := Vector2(gx + cos(sa) * 22, gy - 26 + sin(sa * 1.3) * 12)
		draw_colored_polygon(PackedVector2Array([sp + Vector2(0, -4), sp + Vector2(1.2, -1.2), sp + Vector2(4, 0), sp + Vector2(1.2, 1.2), sp + Vector2(0, 4), sp + Vector2(-1.2, 1.2), sp + Vector2(-4, 0), sp + Vector2(-1.2, -1.2)]), Color("fffbe0"))


func _draw_tomb(c: CanvasItem, center: Vector2, text: String, a: float, sc: float) -> void:
	if sc <= 0.01:
		return
	c.draw_set_transform(center, 0.0, Vector2(sc, sc))
	var pts := PackedVector2Array([Vector2(-44, 34), Vector2(-44, -6)])
	for k in range(1, 12):
		var an := PI + PI * k / 12.0
		pts.append(Vector2(cos(an) * 44.0, -6.0 + sin(an) * 44.0))
	pts.append(Vector2(44, -6))
	pts.append(Vector2(44, 34))
	var fill := Color("d9d3c4")
	fill.a = a
	c.draw_colored_polygon(pts, fill)
	var o := pts.duplicate()
	o.append(pts[0])
	c.draw_polyline(o, Color(INK, a), 3.5, true)
	c.draw_string(font, Vector2(-14, -22), "RIP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("8a5a35", a))
	var lines := _wrap(text, 13, 78.0)
	for j in lines.size():
		var w := font.get_string_size(lines[j], HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		c.draw_string(font, Vector2(-w / 2.0, -4 + j * 15), lines[j], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(INK, a))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_fx() -> void:
	for l in leaves:
		fx.draw_set_transform(l["p"], l["rot"], Vector2(1.0, 0.55))
		fx.draw_circle(Vector2.ZERO, 5.0, l["c"])
	fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for q in parts:
		var col: Color = q["c"]
		col.a = clampf(q["l"] / 0.5, 0.0, 1.0)
		var s: float = q["s"]
		fx.draw_rect(Rect2(q["p"] - Vector2(s, s) / 2.0, Vector2(s, s)), col)
		fx.draw_rect(Rect2(q["p"] - Vector2(s, s) / 2.0, Vector2(s, s)), Color(INK, col.a), false, 1.5)
	for rg in rings:
		var ra: float = rg["age"]
		var al := clampf(1.0 - ra / 0.5, 0.0, 1.0)
		fx.draw_set_transform(rg["p"], 0.0, Vector2(1.0, 0.32))
		fx.draw_arc(Vector2.ZERO, 8.0 + ra * (300.0 if rg["sup"] else 190.0), 0.0, TAU, 32, Color(INK, al * 0.8), 7.0)
		fx.draw_arc(Vector2.ZERO, 8.0 + ra * (300.0 if rg["sup"] else 190.0), 0.0, TAU, 32, Color("fff6a0") if rg["sup"] else Color("fffbe0"), 4.0)
		fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _in_game():
		var mp: Vector2 = MINIS[level_idx]
		if mini_active:
			var bob := sin(t_anim * 3.0) * 3.0
			fx.draw_circle(mp + Vector2(0, bob), 24.0 + sin(t_anim * 5.0) * 2.0, Color(1.0, 0.9, 0.3, 0.28))
			PlayerScript.gold = true
			var hh := PlayerScript.hat
			PlayerScript.hat = 0
			PlayerScript.draw_pumpkin(fx, mp + Vector2(0, 11 + bob), Vector2(0.7, 0.7), 1, 3, 0.0)
			PlayerScript.hat = hh
			PlayerScript.gold = false
			for k in 3:
				var a := t_anim * 2.0 + k * TAU / 3.0
				_star(fx, mp + Vector2(cos(a), sin(a) * 0.7) * 22.0 + Vector2(0, bob), 3.0 + sin(t_anim * 6.0 + k), Color("fff6a0"))
		else:
			fx.draw_arc(mp, 10.0, 0.0, TAU, 16, Color(1, 1, 1, 0.3), 2.0)
		# hovering a pad shows its tombstone
		if player.alive:
			for p in pads:
				var pc: Vector2i = p["cell"]
				var epi: String = p.get("epi", "")
				if epi != "" and absf(player.position.x - (pc.x * T + 16)) < 40.0 and absf(player.position.y - (pc.y * T)) < 110.0:
					_draw_tomb(fx, Vector2(pc.x * T + 16, maxf(pc.y * T - 34.0, 120.0)), epi, 0.92, 0.62)
		for tb in tombs:
			var ta: float = tb["age"]
			var al2 := clampf((2.6 - ta) / 0.5, 0.0, 1.0)
			var sc := 0.9 * clampf(ta / 0.18, 0.0, 1.0)
			_draw_tomb(fx, tb["p"] + Vector2(0, -34.0 - minf(ta * 8.0, 16.0)), tb["t"], al2, sc)
	for q in pops:
		var age: float = q["age"]
		var k := 1.0 + 0.5 * sin(minf(age * 9.0, PI)) if age < 0.35 else 1.0
		var a := clampf((0.95 - age) / 0.3, 0.0, 1.0)
		fx.draw_set_transform(q["p"], q["rot"], Vector2(k, k))
		var s := int(q["s"])
		var w := font.get_string_size(q["t"], HORIZONTAL_ALIGNMENT_LEFT, -1, s).x
		var col: Color = q["c"]
		col.a = a
		fx.draw_string_outline(font, Vector2(-w / 2.0, 0), q["t"], HORIZONTAL_ALIGNMENT_LEFT, -1, s, 12, Color(INK, a))
		fx.draw_string(font, Vector2(-w / 2.0, 0), q["t"], HORIZONTAL_ALIGNMENT_LEFT, -1, s, col)
	fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ------------------------------------------------------------------------ HUD
func _sunburst(c: CanvasItem, center: Vector2, c1: Color) -> void:
	c.draw_rect(Rect2(0, 0, SW, SH), Color(1.0, 0.62, 0.2, 0.93))
	var n := 18
	for i in n:
		var a0 := t_anim * 0.12 + i * TAU / n
		var a1 := a0 + TAU / n * 0.5
		c.draw_colored_polygon(PackedVector2Array([center, center + Vector2(cos(a0), sin(a0)) * 1200.0, center + Vector2(cos(a1), sin(a1)) * 1200.0]), c1)


func _draw_hud() -> void:
	match state:
		"splash":
			_draw_splash()
		"title":
			_draw_title()
			if title_fade > 0.0:
				hud.draw_rect(Rect2(0, 0, SW, SH), Color(0.1, 0.1, 0.12, title_fade))
		"end":
			_draw_end()
		"levels":
			_draw_levels()
		"hats":
			_draw_hats()
		"cutscene":
			_draw_cutscene()
			if touch_mode:
				_sticker_text(hud, "SKIP >>", Vector2(887, 29), 22, 0.0)
		_:
			_draw_play_hud()


func _draw_play_hud() -> void:
	var lv := "LEVEL %d / %d" % [level_idx + 1, LEVELS.size()]
	_sticker_text(hud, lv, Vector2(110, 32), 22, -0.03)
	var pad_txt := "PADS %d/%d" % [pads.size(), max_pads]
	var full := pads.size() >= max_pads and max_pads < MAX_PADS
	var st := "OOPSIES %d     %s" % [deaths_total, pad_txt]
	var w := font.get_string_size(st, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	_sticker(hud, Vector2(SW - w / 2.0 - 36, 32), Vector2(w + 44, 40), 0.02)
	hud.draw_string(font, Vector2(SW - w - 36 - 2, 40), st, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("c9301f") if full else INK)
	# speedrun timer + personal best
	_sticker(hud, Vector2(96, 88), Vector2(158, 58), -0.02)
	hud.draw_string(font, Vector2(28, 86), "TIME " + _fmt_time(ltime), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e8432b") if timer_on else INK)
	var bt: float = sv.best[level_idx]
	hud.draw_string(font, Vector2(28, 107), "BEST " + (_fmt_time(bt) if bt >= 0.0 else "--"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("8a5a35"))
	# bounce back counter
	_sticker(hud, Vector2(96, 140), Vector2(158, 34), 0.015)
	hud.draw_string(font, Vector2(24, 147), "BOUNCE BACKS %d" % bb_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, INK)
	if mini_active:
		PlayerScript.gold = true
		var hh := PlayerScript.hat
		PlayerScript.hat = 0
		PlayerScript.draw_pumpkin(hud, Vector2(200, 152), Vector2(0.6, 0.6), 1, 3, 0.0)
		PlayerScript.hat = hh
		PlayerScript.gold = false
	elif sv.minis[level_idx]:
		_draw_check(hud, Vector2(200, 140))
	if not touch_mode:
		_txt(hud, "ESC: settings", Vector2(18, 184), 16, CREAM, 6)
	var hint: String = LEVELS[level_idx]["hint"]
	_sticker_text(hud, hint, Vector2(SW / 2.0, 84), 22, 0.0)
	if toast_t > 0.0:
		_draw_toast(hud)
	if touch_mode:
		_draw_touch()

	if intro_t > 0.0:
		var L: Dictionary = LEVELS[level_idx]
		var e := clampf((1.9 - intro_t) / 0.35, 0.0, 1.0)
		var out := clampf(intro_t / 0.4, 0.0, 1.0)
		var slide := (1.0 - e) * (1.0 - e) * 700.0 - (1.0 - out) * 700.0
		var cy := 215.0
		hud.draw_set_transform(Vector2(SW / 2.0 + slide, cy), -0.04, Vector2.ONE)
		var name_w := font.get_string_size(L["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 58).x
		var lab := "LEVEL %d" % (level_idx + 1)
		if L.has("chap"):
			lab += "  -  " + String(L["chap"])
		var lw := font.get_string_size(lab, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
		var bw := maxf(name_w, lw)
		hud.draw_style_box(sb_sticker, Rect2(-bw / 2.0 - 36, -62, bw + 72, 128))
		hud.draw_string(font, Vector2(-lw / 2.0, -26), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e8432b"))
		hud.draw_string_outline(font, Vector2(-name_w / 2.0, 34), L["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 58, 0, INK)
		hud.draw_string(font, Vector2(-name_w / 2.0, 34), L["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 58, INK)
		hud.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_title() -> void:
	_sunburst(hud, Vector2(SW / 2.0, 260), Color(1.0, 0.85, 0.3, 0.42))
	_wobble_word(hud, "FAIL", SW / 2.0, 150, 124, 0)
	_wobble_word(hud, "FORWARD", SW / 2.0, 258, 100, 2)
	_sticker_text(hud, "a game about being REALLY bad at games", Vector2(SW / 2.0, 306), 26, -0.03)

	# mascot bouncing on its own oops
	var ph := fposmod(t_anim * 1.5, 1.0)
	var h := 4.0 * ph * (1.0 - ph) * 150.0
	var base := Vector2(110, 452)
	var sq := Vector2(1.25, 0.75) if (ph < 0.08 or ph > 0.92) else Vector2(0.88, 1.14)
	_draw_pad(hud, base.x, base.y + 2, maxf(0.0, 1.0 - ph * 6.0), 0.0, 1.6)
	PlayerScript.draw_pumpkin(hud, Vector2(base.x, base.y - 28 - h), sq * 2.2, 1, 1 if h > 8 else 3, 0.0)
	if ph < 0.25:
		_txtc(hud, "BOING!", base.x + 70, base.y - 90 - ph * 60, 34, Color("f6e05a"), 10)

	var rects := _title_btn_rects()
	var labels := ["CONTINUE" if sv.reach > 0 else "PLAY", "LEVELS", "HATS", "SETTINGS", "ITCH.IO"]
	for i in 5:
		var r: Rect2 = rects[i]
		var sel := i == title_sel
		var k := 1.0 + (sin(t_anim * 6.0) * 0.04 + 0.06 if sel else 0.0)
		hud.draw_set_transform(r.get_center(), (sin(t_anim * 2.0 + i) * 0.02), Vector2(k, k))
		var rr := Rect2(-r.size / 2.0, r.size)
		hud.draw_style_box(sb_sel if sel else sb_sticker, rr)
		var fs := 44 if i == 0 else 28
		var tw := font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		hud.draw_string(font, Vector2(-tw / 2.0, fs * 0.36), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("e8432b") if (i == 0 or i == 4) else INK)
		hud.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if touch_mode:
		_txtc(hud, "tap the buttons - hold JUMP on a pad for a super boing!", SW / 2.0 + 60.0, 508, 18, CREAM, 6)
	else:
		var items := [["ARROWS", "move"], ["SPACE", "jump"], ["R", "retry"], ["ESC", "settings"], ["F", "fullscreen"]]
		var total := 0.0
		for it in items:
			total += font.get_string_size(it[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 18.0 + font.get_string_size(it[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 26.0
		var x := SW / 2.0 - total / 2.0 + 60.0
		for it in items:
			x += _keycap(hud, it[0], x, 472) + 8.0
			_txt(hud, it[1], Vector2(x, 495), 20, CREAM, 6)
			x += font.get_string_size(it[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 18.0
		_txtc(hud, "tip: hold JUMP on a pad for a super boing   (gamepad works too!)", SW / 2.0 + 60.0, 530, 16, CREAM, 6)
	if toast_t > 0.0:
		_draw_toast(hud)


func _draw_toast(c: CanvasItem) -> void:
	var a := clampf(toast_t / 0.4, 0.0, 1.0)
	var slide := (1.0 - clampf((3.2 - toast_t) / 0.3, 0.0, 1.0)) * -60.0
	var w := font.get_string_size(toast_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	c.draw_set_transform(Vector2(SW / 2.0, 150.0 + slide), -0.02, Vector2.ONE)
	c.draw_style_box(sb_sel, Rect2(-w / 2.0 - 22, -26, w + 44, 52))
	c.draw_string(font, Vector2(-w / 2.0, 9), toast_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(INK, a))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


const SPLASH_END := 5.2


func _title_btn_rects() -> Array:
	var cx := SW / 2.0 + 105.0
	var out := [Rect2(cx - 160.0, 372.0 - 38.0, 320.0, 76.0)]
	var ws := [140.0, 120.0, 160.0, 140.0]
	var total := 14.0 * 3.0
	for w in ws:
		total += w
	var x := cx - total / 2.0
	for w in ws:
		out.append(Rect2(x, 436.0 - 25.0, w, 50.0))
		x += w + 14.0
	return out


func _start_game_from_title() -> void:
	if not music.playing:
		music.play()
	if sv.reach > 0:
		state = "play"
		load_level(int(sv.reach))
	else:
		deaths_total = 0
		_start_cutscene("intro", 0)


func _title_activate(i: int) -> void:
	_play("pop")
	match i:
		0:
			_start_game_from_title()
		1:
			lv_sel = clampi(int(sv.reach), 0, LEVELS.size() - 1)
			state = "levels"
		2:
			hat_sel = int(sv.hat)
			state = "hats"
		3:
			_open_menu()
		4:
			OS.shell_open(ITCH_URL)


func _title_input() -> void:
	var rects := _title_btn_rects()
	var old := title_sel
	if Input.is_action_just_pressed("left"):
		title_sel = (title_sel + 4) % 5
	if Input.is_action_just_pressed("right"):
		title_sel = (title_sel + 1) % 5
	if Input.is_action_just_pressed("menu_up") and title_sel > 0:
		title_sel = 0
	if Input.is_action_just_pressed("menu_down") and title_sel == 0:
		title_sel = 2
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mp := get_viewport().get_mouse_position()
	if mp != title_last_mouse:
		title_last_mouse = mp
		for i in 5:
			if rects[i].has_point(mp):
				title_sel = i
	if title_sel != old:
		_play("tick")
	if title_fade > 0.5:
		title_mouse_down = down
		return
	var enter := Input.is_key_pressed(KEY_ENTER)
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("menu_ok") or (enter and not title_enter_held):
		title_enter_held = enter
		_title_activate(title_sel)
		return
	title_enter_held = enter
	if down and not title_mouse_down:
		for i in 5:
			if rects[i].has_point(mp):
				title_sel = i
				title_mouse_down = true
				_title_activate(i)
				return
	title_mouse_down = down


# ------------------------------------------------------------ level select
const LV_COLS := 6
const LV_W := 142.0
const LV_H := 74.0
const LV_GAP := 8.0


func _lv_rect(i: int) -> Rect2:
	var x0 := (SW - (LV_COLS * LV_W + (LV_COLS - 1) * LV_GAP)) / 2.0
	return Rect2(x0 + (i % LV_COLS) * (LV_W + LV_GAP), 96.0 + (i / LV_COLS) * (LV_H + LV_GAP), LV_W, LV_H)


const BACK_RECT := Rect2(18, 500, 120, 36)


func _back_pressed() -> bool:
	return Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_back") or (clicked and BACK_RECT.has_point(get_viewport().get_mouse_position()))


func _levels_input() -> void:
	var old := lv_sel
	var n := LEVELS.size()
	if Input.is_action_just_pressed("left"):
		lv_sel = maxi(lv_sel - 1, 0)
	if Input.is_action_just_pressed("right"):
		lv_sel = mini(lv_sel + 1, n - 1)
	if Input.is_action_just_pressed("menu_up") and lv_sel >= LV_COLS:
		lv_sel -= LV_COLS
	if Input.is_action_just_pressed("menu_down") and lv_sel + LV_COLS < n:
		lv_sel += LV_COLS
	var mp := get_viewport().get_mouse_position()
	if mp != last_mouse:
		last_mouse = mp
		for i in n:
			if _lv_rect(i).has_point(mp):
				lv_sel = i
	if lv_sel != old:
		_play("tick")
	if _back_pressed():
		state = "title"
		title_mouse_down = true
		return
	var go := Input.is_action_just_pressed("menu_ok")
	if clicked:
		for i in n:
			if _lv_rect(i).has_point(mp):
				lv_sel = i
				go = true
	if go:
		if lv_sel > int(sv.reach):
			_play("land")
			_toast("Finish the earlier levels first!")
			return
		if not music.playing:
			music.play()
		_play("pop")
		state = "play"
		load_level(lv_sel)


func _draw_check(c: CanvasItem, p: Vector2) -> void:
	c.draw_circle(p, 10.0, INK)
	c.draw_circle(p, 8.0, Color("8cc63f"))
	c.draw_polyline(PackedVector2Array([p + Vector2(-4, 0), p + Vector2(-1, 3.5), p + Vector2(5, -3.5)]), Color.WHITE, 2.6)


func _draw_levels() -> void:
	_sunburst(hud, Vector2(SW / 2.0, 260), Color(1.0, 0.85, 0.3, 0.3))
	_wobble_word(hud, "PICK A LEVEL", SW / 2.0, 56, 46, 1)
	for i in LEVELS.size():
		var r := _lv_rect(i)
		var locked := i > int(sv.reach)
		var sel := i == lv_sel
		var k := 1.04 if sel else 1.0
		hud.draw_set_transform(r.get_center(), 0.0, Vector2(k, k))
		var rr := Rect2(-r.size / 2.0, r.size)
		hud.draw_style_box(sb_sel if sel else (sb_lock if locked else sb_sticker), rr)
		var ox := -r.size.x / 2.0
		var oy := -r.size.y / 2.0
		hud.draw_string(font, Vector2(ox + 10, oy + 30), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("8a6a4a") if locked else Color("e8432b"))
		hud.draw_string(font, Vector2(ox + 10, oy + 49), _fit(LEVELS[i]["name"], 13, r.size.x - 18.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK if not locked else Color("6e5238"))
		if locked:
			hud.draw_string(font, Vector2(ox + 10, oy + 67), "LOCKED", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6e5238"))
		elif sv.done[i]:
			hud.draw_string(font, Vector2(ox + 10, oy + 67), _fmt_time(sv.best[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK)
			var dt := "oops %d" % int(sv.ldeaths[i])
			var dw := font.get_string_size(dt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
			hud.draw_string(font, Vector2(ox + r.size.x - dw - 10, oy + 67), dt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("c9301f"))
			_draw_check(hud, Vector2(ox + r.size.x - 16, oy + 16))
		else:
			hud.draw_string(font, Vector2(ox + 10, oy + 67), "NEW!" if i == int(sv.reach) else "...", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8432b"))
		if not locked:
			var mc := Vector2(ox + r.size.x - 44, oy + 24)
			if sv.minis[i]:
				PlayerScript.gold = true
				var hh := PlayerScript.hat
				PlayerScript.hat = 0
				PlayerScript.draw_pumpkin(hud, mc + Vector2(0, 9), Vector2(0.5, 0.5), 1, 3, 0.0)
				PlayerScript.hat = hh
				PlayerScript.gold = false
			else:
				hud.draw_arc(mc, 8.0, 0.0, TAU, 14, Color(0.55, 0.4, 0.2, 0.5), 2.0)
		hud.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	hud.draw_style_box(sb_sel if false else sb_sticker, BACK_RECT)
	_txtc(hud, "< BACK", BACK_RECT.get_center().x, BACK_RECT.get_center().y + 8, 22, INK, 0)
	var st := "secret pumpkins %d/%d     bounce backs %d     oopsies %d" % [sv.count_minis(), LEVELS.size(), int(sv.bounces), int(sv.deaths)]
	_txtc(hud, st, SW / 2.0 + 70.0, 526, 20, CREAM, 6)
	if toast_t > 0.0:
		_draw_toast(hud)


# ---------------------------------------------------------------- wardrobe
func _hat_rect(i: int) -> Rect2:
	var w := 140.0
	var g := 12.0
	var x0 := (SW - (HATS.size() * w + (HATS.size() - 1) * g)) / 2.0
	return Rect2(x0 + i * (w + g), 130.0, w, 300.0)


func _hats_input() -> void:
	var old := hat_sel
	var n := HATS.size()
	if Input.is_action_just_pressed("left"):
		hat_sel = maxi(hat_sel - 1, 0)
	if Input.is_action_just_pressed("right"):
		hat_sel = mini(hat_sel + 1, n - 1)
	var mp := get_viewport().get_mouse_position()
	if mp != last_mouse:
		last_mouse = mp
		for i in n:
			if _hat_rect(i).has_point(mp):
				hat_sel = i
	if hat_sel != old:
		_play("tick")
	if _back_pressed():
		state = "title"
		title_mouse_down = true
		return
	var go := Input.is_action_just_pressed("menu_ok")
	if clicked:
		for i in n:
			if _hat_rect(i).has_point(mp):
				hat_sel = i
				go = true
	if go:
		if _hat_unlocked(hat_sel):
			sv.hat = hat_sel
			PlayerScript.hat = hat_sel
			sv.save_file()
			_play("pop")
		else:
			_play("land")


func _draw_hats() -> void:
	_sunburst(hud, Vector2(SW / 2.0, 260), Color(1.0, 0.85, 0.3, 0.3))
	_wobble_word(hud, "HAT SHOP", SW / 2.0, 66, 56, 3)
	_txtc(hud, "wear them in the game - and in the story!", SW / 2.0, 108, 20, CREAM, 6)
	for i in HATS.size():
		var r := _hat_rect(i)
		var open := _hat_unlocked(i)
		var sel := i == hat_sel
		var k := 1.04 if sel else 1.0
		hud.draw_set_transform(r.get_center(), 0.0, Vector2(k, k))
		var rr := Rect2(-r.size / 2.0, r.size)
		hud.draw_style_box(sb_sel if sel else (sb_sticker if open else sb_lock), rr)
		hud.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var cx := r.get_center().x
		var keep := PlayerScript.hat
		PlayerScript.hat = i
		var bob := absf(sin(t_anim * 3.0 + i)) * 8.0 if (sel and open) else 0.0
		if open:
			PlayerScript.draw_pumpkin(hud, Vector2(cx, r.position.y + 150 - bob), Vector2(2.4, 2.4), 1, 3 if sel else 0, 0.0)
		else:
			PlayerScript.draw_pumpkin(hud, Vector2(cx, r.position.y + 150), Vector2(2.4, 2.4), 1, 4, 0.0)
			hud.draw_rect(Rect2(r.position + Vector2(6, 40), Vector2(r.size.x - 12, 130)), Color(0.35, 0.25, 0.15, 0.55))
			_txtc(hud, "LOCKED", cx, r.position.y + 112, 24, CREAM, 6)
		PlayerScript.hat = keep
		_txtc(hud, HATS[i]["name"], cx, r.position.y + 196, 22, INK if open else Color("6e5238"), 0)
		var lines := _wrap(String(HATS[i]["how"]), 15, r.size.x - 20.0)
		for j in lines.size():
			_txtc(hud, lines[j], cx, r.position.y + 222 + j * 17, 15, Color("8a5a35"), 0)
		if i > 0:
			_txtc(hud, _hat_progress(i), cx, r.position.y + 274, 20, Color("e8432b") if not open else Color("5f9a2a"), 0)
		if open and i == int(sv.hat):
			_sticker_text(hud, "WEARING", Vector2(cx, r.position.y + 6), 16, -0.05, INK, 10.0)
	hud.draw_style_box(sb_sticker, BACK_RECT)
	_txtc(hud, "< BACK", BACK_RECT.get_center().x, BACK_RECT.get_center().y + 8, 22, INK, 0)
	_txtc(hud, "LEFT / RIGHT pick     SPACE wear", SW / 2.0 + 70.0, 526, 20, CREAM, 6)


func _draw_splash() -> void:
	hud.draw_rect(Rect2(0, 0, SW, SH), Color(0.1, 0.1, 0.12))
	var a := smoothstep(0.0, 1.8, splash_t) * (1.0 - smoothstep(3.4, SPLASH_END, splash_t))
	if logo_tex == null:
		return
	var sz := 300.0 + splash_t * 8.0
	var r := Rect2(Vector2(SW / 2.0 - sz / 2.0, SH / 2.0 - sz / 2.0 - 10.0), Vector2(sz, sz))
	hud.draw_texture_rect(logo_tex, r, false, Color(1, 1, 1, a))


func _draw_end() -> void:
	_sunburst(hud, Vector2(SW / 2.0, 250), Color(1.0, 0.9, 0.4, 0.45))
	_wobble_word(hud, "YOU", SW / 2.0, 140, 110, 1)
	_wobble_word(hud, "WIN!!", SW / 2.0, 245, 110, 3)
	var rank := "Legend. You failed more than the game expected."
	if deaths_total <= 12:
		rank = "Suspiciously good. Are you cheating?"
	elif deaths_total <= 40:
		rank = "A respectable pile of oopsies."
	elif deaths_total <= 100:
		rank = "Professional failer. Frame this."
	_sticker_text(hud, "You oopsed %d times. Every one helped!" % deaths_total, Vector2(SW / 2.0, 310), 30, -0.02)
	_sticker_text(hud, rank, Vector2(SW / 2.0, 368), 24, 0.015)
	if sv.count_minis() >= LEVELS.size():
		_sticker_text(hud, "ALL SECRET PUMPKINS FOUND! Crown unlocked!", Vector2(SW / 2.0, 410), 22, -0.01, Color("c9301f"))
	else:
		_txtc(hud, "secret pumpkins found: %d / %d  (look behind you!)" % [sv.count_minis(), LEVELS.size()], SW / 2.0, 412, 20, CREAM, 6)
	var ph := fposmod(t_anim * 1.7, 1.0)
	var h := 4.0 * ph * (1.0 - ph) * 110.0
	PlayerScript.draw_pumpkin(hud, Vector2(SW / 2.0 - 330, 440 - h), Vector2(2.0, 2.0), 1, 3, 0.0)
	PlayerScript.draw_pumpkin(hud, Vector2(SW / 2.0 + 330, 440 - h), Vector2(2.0, 2.0), -1, 3, 0.0)
	var pulse := 1.0 + sin(t_anim * 5.0) * 0.05
	hud.draw_set_transform(Vector2(SW / 2.0, 450), 0.0, Vector2(pulse, pulse))
	var pw := font.get_string_size("SPACE = MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x
	hud.draw_style_box(sb_sticker, Rect2(-pw / 2.0 - 28, -36, pw + 56, 72))
	hud.draw_string(font, Vector2(-pw / 2.0, 14), "SPACE = MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color("e8432b"))
	hud.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---------------------------------------------------------------------- audio
func _tone_bytes(f0: float, f1: float, dur: float, vol: float, wave: int) -> PackedByteArray:
	var n := int(dur * RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var u := float(i) / n
		phase += lerpf(f0, f1, u) / RATE
		var ph := fposmod(phase, 1.0)
		var s := 0.0
		match wave:
			0:
				s = sin(TAU * ph)
			1:
				s = 0.55 if ph < 0.5 else -0.55
			_:
				s = 4.0 * absf(ph - 0.5) - 1.0
		var env := minf(1.0, i / 150.0) * pow(1.0 - u, 1.4)
		data.encode_s16(i * 2, int(clampf(s * env * vol, -1.0, 1.0) * 32767.0))
	return data


func _wav(bytes: PackedByteArray, rate: int) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	return w


func _seq(freqs: Array, note_dur: float, vol: float, wave: int) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	for f in freqs:
		bytes.append_array(_tone_bytes(f, f, note_dur, vol, wave))
	return _wav(bytes, RATE)


func _add_note(buf: PackedFloat32Array, midi: int, start: float, dur: float, vol: float) -> void:
	var f := 440.0 * pow(2.0, (midi - 69) / 12.0)
	var i0 := int(start * MUSIC_RATE)
	var cnt := int(dur * MUSIC_RATE)
	for i in cnt:
		var idx := i0 + i
		if idx >= buf.size():
			break
		var ph := fposmod(f * i / MUSIC_RATE, 1.0)
		var s := 4.0 * absf(ph - 0.5) - 1.0
		var env := minf(1.0, i / 200.0) * exp(-3.2 * i / cnt)
		buf[idx] += s * env * vol


func _add_noise(buf: PackedFloat32Array, start: float, dur: float, vol: float, decay: float) -> void:
	var i0 := int(start * MUSIC_RATE)
	var cnt := int(dur * MUSIC_RATE)
	for i in cnt:
		var idx := i0 + i
		if idx >= buf.size():
			break
		buf[idx] += (randf() * 2.0 - 1.0) * vol * exp(-decay * i / cnt)


func _add_kick(buf: PackedFloat32Array, start: float, vol: float) -> void:
	var i0 := int(start * MUSIC_RATE)
	var cnt := int(0.14 * MUSIC_RATE)
	var ph := 0.0
	for i in cnt:
		var idx := i0 + i
		if idx >= buf.size():
			break
		var u := float(i) / cnt
		ph += lerpf(130.0, 42.0, minf(u * 2.2, 1.0)) / MUSIC_RATE
		buf[idx] += sin(TAU * ph) * vol * pow(1.0 - u, 1.6)


func _make_music() -> AudioStreamWAV:
	var step := 0.2
	var steps := 64
	var n := int(step * steps * MUSIC_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var mel_a := [69, 72, 76, 72, 69, 72, 76, 79, 69, 72, 77, 72, 69, 72, 77, 81,
		67, 72, 76, 72, 67, 72, 76, 79, 67, 71, 74, 71, 67, 71, 74, 79]
	var mel_b := [81, 79, 76, 79, 81, 84, 81, 79, 77, 76, 72, 76, 77, 81, 77, 76,
		79, 76, 72, 76, 79, 84, 79, 76, 79, 74, 71, 74, 79, 83, 86, 83]
	var bass := [45, 41, 48, 43]
	for s2 in 32:
		_add_note(buf, mel_a[s2], s2 * step, 0.34, 0.18)
		_add_note(buf, mel_b[s2], (32 + s2) * step, 0.30, 0.18)
		# soft arpeggio an octave down on the second half
		_add_note(buf, int(mel_b[s2]) - 12, (32 + s2) * step + 0.1, 0.18, 0.07)
	for c2 in 8:
		_add_note(buf, bass[c2 % 4], c2 * 8 * step, 1.5, 0.30)
		_add_note(buf, int(bass[c2 % 4]) + 7, c2 * 8 * step + 0.8, 0.7, 0.10)
	for s3 in steps:
		if s3 % 4 == 0:
			_add_kick(buf, s3 * step, 0.38)
		if s3 % 4 == 2 and s3 >= 8:
			_add_noise(buf, s3 * step, 0.05, 0.10, 4.0)
		if s3 % 8 == 4:
			_add_noise(buf, s3 * step, 0.12, 0.20, 3.0)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		bytes.encode_s16(i * 2, int(clampf(buf[i] * 0.85, -1.0, 1.0) * 32767.0))
	var w := _wav(bytes, MUSIC_RATE)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = n
	return w


func _load_custom(sname: String) -> AudioStream:
	for ext in ["ogg", "mp3", "wav"]:
		var path := "res://audio/%s.%s" % [sname, ext]
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is AudioStream:
				return res
	return null


func _setup_buses() -> void:
	for bname in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bname) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(idx, bname)
			AudioServer.set_bus_send(idx, "Master")


func _make_audio() -> void:
	snd["jump"] = _wav(_tone_bytes(280, 560, 0.12, 0.35, 1), RATE)
	snd["land"] = _wav(_tone_bytes(160, 70, 0.07, 0.35, 0), RATE)
	snd["bounce"] = _wav(_tone_bytes(220, 880, 0.28, 0.5, 2), RATE)
	snd["super"] = _wav(_tone_bytes(260, 1500, 0.4, 0.5, 2), RATE)
	snd["death"] = _wav(_tone_bytes(420, 50, 0.45, 0.45, 1), RATE)
	snd["pop"] = _wav(_tone_bytes(500, 900, 0.1, 0.3, 0), RATE)
	snd["talk"] = _wav(_tone_bytes(380, 440, 0.035, 0.16, 1), RATE)
	var caw := _tone_bytes(760, 430, 0.13, 0.4, 1)
	caw.append_array(_tone_bytes(720, 380, 0.17, 0.4, 1))
	snd["caw"] = _wav(caw, RATE)
	snd["win"] = _seq([523.25, 659.25, 783.99, 1046.5], 0.11, 0.45, 2)
	snd["coin"] = _seq([987.77, 1318.5, 1975.5], 0.07, 0.4, 2)
	snd["unlock"] = _seq([523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0], 0.09, 0.45, 2)
	snd["tick"] = _wav(_tone_bytes(700.0, 900.0, 0.03, 0.22, 0), RATE)
	# your own files in res://audio/ (jump, land, bounce, super, death, pop, win, music) win over these
	for k in snd.keys():
		var custom := _load_custom(k)
		if custom != null:
			snd[k] = custom
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
	music = AudioStreamPlayer.new()
	var cm := _load_custom("music")
	if cm != null:
		music.stream = cm
		music.finished.connect(music.play)   # loop any custom track
	else:
		music.stream = _make_music()
	music.bus = "Music"
	music.volume_db = -10.0
	add_child(music)


func _play(sname: String) -> void:
	var p: AudioStreamPlayer = sfx_players[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_players.size()
	p.stream = snd[sname]
	p.play()


# ------------------------------------------------------------- settings menu
func _load_settings() -> void:
	var cf := ConfigFile.new()
	if cf.load("user://settings.cfg") == OK:
		music_vol = clampf(float(cf.get_value("audio", "music", 0.8)), 0.0, 1.0)
		sfx_vol = clampf(float(cf.get_value("audio", "sfx", 0.8)), 0.0, 1.0)
		bright = clampf(float(cf.get_value("video", "brightness", 1.0)), 0.5, 1.5)
		shake_amt = clampf(float(cf.get_value("video", "shake", 1.0)), 0.0, 1.0)


func _save_settings() -> void:
	var cf := ConfigFile.new()
	cf.set_value("audio", "music", music_vol)
	cf.set_value("audio", "sfx", sfx_vol)
	cf.set_value("video", "brightness", bright)
	cf.set_value("video", "shake", shake_amt)
	cf.save("user://settings.cfg")


func _apply_settings() -> void:
	var mi := AudioServer.get_bus_index("Music")
	var si := AudioServer.get_bus_index("SFX")
	if mi >= 0:
		AudioServer.set_bus_volume_db(mi, linear_to_db(maxf(music_vol, 0.0001)))
		AudioServer.set_bus_mute(mi, music_vol <= 0.001)
	if si >= 0:
		AudioServer.set_bus_volume_db(si, linear_to_db(maxf(sfx_vol, 0.0001)))
		AudioServer.set_bus_mute(si, sfx_vol <= 0.001)
	if dark_rect != null:
		dark_rect.color = Color(0, 0, 0, clampf((1.0 - bright) * 1.2, 0.0, 0.6))
		light_rect.color = Color(1, 1, 1, clampf((bright - 1.0) * 0.5, 0.0, 0.25))


func _in_game() -> bool:
	return state == "play" or state == "dead" or state == "clear"


func _menu_rows() -> Array:
	var rows := [["slider", "MUSIC"], ["slider", "SOUND FX"], ["slider", "BRIGHTNESS"], ["slider", "SCREEN SHAKE"]]
	if _in_game():
		rows.append(["btn", "RESUME"])
		rows.append(["btn", "RETRY LEVEL"])
		rows.append(["btn", "MAIN MENU"])
	else:
		rows.append(["btn", "BACK"])
		rows.append(["btn", "REALLY? PRESS AGAIN" if reset_armed else "RESET PROGRESS"])
	return rows


func _menu_top() -> float:
	var h := 150.0 + _menu_rows().size() * 54.0
	return (SH - h) / 2.0


func _row_rect(i: int) -> Rect2:
	return Rect2(190, _menu_top() + 92.0 + i * 54.0, 580, 46)


func _slider_value(i: int) -> float:
	match i:
		0:
			return music_vol
		1:
			return sfx_vol
	if i == 3:
		return shake_amt
	return (bright - 0.5)   # 0..1


func _set_slider(i: int, v: float) -> void:
	v = clampf(v, 0.0, 1.0)
	match i:
		0:
			music_vol = v
		1:
			sfx_vol = v
		2:
			bright = 0.5 + v
		3:
			shake_amt = v
	_apply_settings()


func _open_menu() -> void:
	menu_open = true
	menu_sel = 0
	rep_t = 0.0
	reset_armed = false
	mouse_was_down = true
	_touch_release_all()
	get_tree().paused = true
	menu_ctrl.visible = true
	menu_ctrl.queue_redraw()


func _close_menu() -> void:
	menu_open = false
	title_mouse_down = true
	_save_settings()
	get_tree().paused = false
	menu_ctrl.visible = false


func _menu_activate(i: int) -> void:
	var rows := _menu_rows()
	var label: String = rows[i][1]
	match label:
		"RESUME", "BACK":
			_close_menu()
		"RESET PROGRESS":
			reset_armed = true
		"REALLY? PRESS AGAIN":
			reset_armed = false
			sv.reset()
			sv.save_file()
			PlayerScript.hat = 0
			deaths_total = 0
			_toast("Progress erased. Fresh start!")
			_close_menu()
		"RETRY LEVEL":
			_close_menu()
			state = "play"
			load_level(level_idx)
		"MAIN MENU":
			_close_menu()
			state = "title"
			load_level(0)
			intro_t = 0.0
			player.alive = false


func _menu_input(delta: float) -> void:
	var rows := _menu_rows()
	drag_snd_t = maxf(0.0, drag_snd_t - delta)
	if Input.is_action_just_pressed("pause"):
		_close_menu()
		return
	if Input.is_action_just_pressed("menu_up"):
		menu_sel = (menu_sel - 1 + rows.size()) % rows.size()
	if Input.is_action_just_pressed("menu_down"):
		menu_sel = (menu_sel + 1) % rows.size()

	var dir := 0
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		rep_t = 0.35
		dir = -1 if Input.is_action_pressed("left") else 1
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		rep_t -= delta
		if rep_t <= 0.0:
			rep_t = 0.06
			dir = -1 if Input.is_action_pressed("left") else 1
	if dir != 0 and rows[menu_sel][0] == "slider":
		_set_slider(menu_sel, _slider_value(menu_sel) + dir * 0.05)
		if menu_sel == 1 and drag_snd_t <= 0.0:
			_play("bounce")
			drag_snd_t = 0.15

	if Input.is_action_just_pressed("menu_ok") and rows[menu_sel][0] == "btn":
		_menu_activate(menu_sel)
		return

	# mouse support
	var mp := menu_ctrl.get_local_mouse_position()
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if mp != last_mouse:
		for i in rows.size():
			if _row_rect(i).has_point(mp):
				menu_sel = i
		last_mouse = mp
	if down:
		for i in rows.size():
			var r := _row_rect(i)
			if not r.has_point(mp):
				continue
			menu_sel = i
			if rows[i][0] == "slider" and mp.x >= BAR_X0 - 14.0 and mp.x <= BAR_X1 + 14.0:
				_set_slider(i, (mp.x - BAR_X0) / (BAR_X1 - BAR_X0))
				if i == 1 and drag_snd_t <= 0.0:
					_play("bounce")
					drag_snd_t = 0.15
			elif rows[i][0] == "btn" and not mouse_was_down:
				mouse_was_down = true
				_menu_activate(i)
				return
	mouse_was_down = down


func _draw_menu() -> void:
	var c := menu_ctrl
	c.draw_rect(Rect2(0, 0, SW, SH), Color(0.17, 0.07, 0.03, 0.62))
	var rows := _menu_rows()
	var top := _menu_top()
	var h := 150.0 + rows.size() * 54.0
	_sticker(c, Vector2(SW / 2.0, top + h / 2.0), Vector2(640, h))
	_wobble_word(c, "SETTINGS", SW / 2.0, top + 66.0, 50, 0)
	for i in rows.size():
		var r := _row_rect(i)
		var sel := i == menu_sel
		if sel:
			c.draw_style_box(sb_sel, r)
		var label: String = rows[i][1]
		if rows[i][0] == "slider":
			c.draw_string(font, Vector2(r.position.x + 20, r.position.y + 34), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, INK)
			var bar := Rect2(BAR_X0, r.position.y + 11, BAR_X1 - BAR_X0, 24)
			c.draw_style_box(sb_bar, bar)
			var v := _slider_value(i)
			var fw := maxf(0.0, (bar.size.x - 10.0) * v)
			if fw > 1.0:
				c.draw_rect(Rect2(bar.position + Vector2(5, 5), Vector2(fw, bar.size.y - 10)), Color("f58a1f") if i < 2 else (Color("f6c935") if i == 2 else Color("8cc63f")))
			_disc(c, Vector2(bar.position.x + 5.0 + fw, bar.position.y + 12), 11.0, Color("e8432b") if sel else Color("fffaf0"), 3.0)
			var txt := "%d%%" % int(round(v * 100.0)) if i != 2 else "%d%%" % int(round(bright * 100.0))
			c.draw_string(font, Vector2(BAR_X1 + 22, r.position.y + 33), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, INK)
		else:
			var tt := ("> " + label + " <") if sel else label
			var w := font.get_string_size(tt, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
			c.draw_string(font, Vector2(r.position.x + r.size.x / 2.0 - w / 2.0, r.position.y + 34), tt, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, INK)
	var f := "UP/DOWN pick     LEFT/RIGHT change     ESC back"
	var fwid := font.get_string_size(f, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
	c.draw_string(font, Vector2(SW / 2.0 - fwid / 2.0, top + h - 18), f, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("8a5a35"))


# ------------------------------------------------------------------ cutscenes
const CUTSCENE_AFTER := {4: "ch2", 9: "ch3", 14: "ch4", 19: "twist1", 24: "twist2", 29: "ending"}

const CUTS := {
	"intro": [
		{"s": "sleep", "who": "", "txt": "Pete the pumpkin had ONE job: guard the harvest basket."},
		{"s": "steal", "who": "CROWFORD", "caw": true, "txt": "CAW! Free snacks!"},
		{"s": "jump", "who": "PETE", "txt": "HEY! GIVE THAT BACK!"},
		{"s": "splat", "who": "", "txt": "Pete is not great at jumping. Or landing. Or anything involving gravity."},
		{"s": "hero", "who": "", "txt": "But Pete has a secret power: every time he FAILS... he bounces back!"},
	],
	"ch2": [
		{"s": "walk", "who": "", "txt": "Pete bounced his way out of Oof Valley. The thief was nowhere in sight."},
		{"s": "taunt", "who": "CROWFORD", "caw": true, "txt": "Come and get it, wimp! My friends the saws say hi."},
		{"s": "saws", "who": "PETE", "txt": "...I should have stayed in bed."},
	],
	"ch3": [
		{"s": "cave", "who": "", "txt": "Deep in the Spiky Caves, something was watching. Something with a beak."},
		{"s": "plan", "who": "CROWFORD", "caw": true, "txt": "Step one: spikes. Step two: MORE spikes. Step three: ??? Step four: apples!"},
		{"s": "shrug", "who": "PETE", "txt": "That is not even a plan."},
	],
	"ch4": [
		{"s": "castle", "who": "", "txt": "At last: Crowford's Castle. Okay, it was a nest. A VERY big nest."},
		{"s": "laugh", "who": "CROWFORD", "caw": true, "txt": "You came all this way for a basket? Fine. Come and get it. CAW HA HA HA!"},
		{"s": "crack", "who": "PETE", "txt": "Oh, I will. And I will fail. A LOT."},
	],
	"twist1": [
		{"s": "cry", "who": "", "txt": "Pete finally reached the basket. And Crowford was... crying?"},
		{"s": "cry", "who": "CROWFORD", "txt": "I just wanted someone to share apples with. Nobody ever visits my nest."},
		{"s": "share", "who": "", "txt": "So Pete shared the apples. Turns out Crowford only wanted a friend."},
		{"s": "empty", "who": "", "txt": "But when the last apple was gone, Pete noticed something. The basket was missing something GOLDEN."},
		{"s": "note", "who": "", "txt": "Taped to the bottom was a note. It was not a nice note."},
		{"s": "confess", "who": "CROWFORD", "caw": true, "txt": "Okay, so... a scarecrow paid me in apples to grab your basket. I did NOT read the fine print."},
		{"s": "farfield", "who": "", "txt": "Far away in the cornfield, a scarecrow held Grandma's Golden Seed. It glowed. Ominously."},
		{"s": "team", "who": "", "txt": "Crowford joined the team. (He still owes Pete a basket.)"},
	],
	"twist2": [
		{"s": "stan", "who": "STAN", "txt": "Welcome to my farm, little pumpkin. You've been bouncing right into my plan."},
		{"s": "stan", "who": "PETE", "txt": "Give back Grandma's Golden Seed, Stan!"},
		{"s": "unmask", "who": "", "txt": "Stan took off his hat. Underneath was... a STEM. Stan was a PUMPKIN."},
		{"s": "unmask", "who": "STAN", "txt": "My name isn't Stan. It's Pat. And I'm your TWIN brother."},
		{"s": "gasp", "who": "PETE", "txt": "PAT?! My TWIN?! ...That hat was a terrible disguise."},
		{"s": "pat", "who": "PAT", "txt": "Grandma planted two seeds. You got the sunny patch. I got a pole in a field. Nobody even waved."},
		{"s": "run", "who": "PAT", "txt": "If I can't have a family... I'll GROW one! See you at the Pumpkin Patch of Destiny!"},
	],
	"ending": [
		{"s": "patch", "who": "", "txt": "At the Pumpkin Patch of Destiny, Pat finally stopped running. And Pete finally caught up."},
		{"s": "plant", "who": "PAT", "txt": "I'm sorry, Pete. Want to plant it together?"},
		{"s": "plant", "who": "PETE", "txt": "Together. Also, nice hat."},
		{"s": "grow", "who": "", "txt": "The Golden Seed grew into a giant pumpkin house. Big enough for the whole family. And Crowford."},
		{"s": "farmer", "who": "FARMER", "txt": "Mmm. PUMPKIN PIE."},
		{"s": "run2", "who": "", "txt": "Pete, Pat and Crowford bounced away. VERY fast."},
		{"s": "end", "who": "", "txt": "THE END... maybe. Pete failed %d times. He regrets nothing. (Crowford regrets a little.)"},
	],
}


func _cs_text() -> String:
	var pg: Dictionary = CUTS[cs_id][cs_page]
	return String(pg["txt"]).replace("%d", str(deaths_total))


func _start_cutscene(id: String, next_level: int) -> void:
	state = "cutscene"
	cs_id = id
	cs_page = 0
	cs_next = next_level
	player.visible = false
	player.alive = false
	_cs_enter()


func _cs_enter() -> void:
	cs_t = 0.0
	cs_chars = 0.0
	cs_blip = 0
	var pg: Dictionary = CUTS[cs_id][cs_page]
	_play("caw" if pg.get("caw", false) else "pop")


func _cutscene_update(delta: float) -> void:
	cs_t += delta
	var full := _cs_text().length()
	if cs_chars < full:
		cs_chars = minf(cs_chars + delta * 40.0, float(full))
		var b := int(cs_chars / 3.0)
		if b != cs_blip:
			cs_blip = b
			_play("talk")
	if clicked and Rect2(820, 6, 134, 46).has_point(get_viewport().get_mouse_position()) and touch_mode:
		_finish_cutscene()
		return
	if Input.is_action_just_pressed("menu_ok") or clicked:
		if cs_chars < full:
			cs_chars = float(full)
		else:
			cs_page += 1
			if cs_page >= CUTS[cs_id].size():
				_finish_cutscene()
			else:
				_cs_enter()
	elif Input.is_action_just_pressed("skip"):
		_finish_cutscene()


func _finish_cutscene() -> void:
	if cs_next >= 0:
		state = "play"
		load_level(cs_next)
	else:
		_show_end()


func _wrap(text: String, size: int, maxw: float) -> Array:
	var lines: Array = []
	var cur := ""
	for w in text.split(" "):
		var test := w if cur == "" else cur + " " + w
		if cur != "" and font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > maxw:
			lines.append(cur)
			cur = w
		else:
			cur = test
	lines.append(cur)
	return lines


func _tag_col(who: String) -> Color:
	match who:
		"PETE":
			return Color("c9301f")
		"CROWFORD":
			return Color("4d4670")
		"STAN", "PAT":
			return Color("a8561a")
		"FARMER":
			return Color("2f5a8a")
	return INK


func _draw_caption(c: CanvasItem, pg: Dictionary) -> void:
	var full := _cs_text()
	var size := 28
	var lines := _wrap(full, size, 760.0)
	var lw := 0.0
	for l in lines:
		lw = maxf(lw, font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
	var h := lines.size() * 36.0 + 30.0
	var center := Vector2(SW / 2.0, SH - 34.0 - h / 2.0)
	_sticker(c, center, Vector2(lw + 64.0, h), 0.0)
	var y := center.y - h / 2.0 + 38.0
	var left := center.x - lw / 2.0
	var rem := int(cs_chars)
	for l in lines:
		c.draw_string(font, Vector2(left, y), l.substr(0, maxi(0, rem)), HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)
		rem -= l.length() + 1
		y += 36.0
	var who: String = pg["who"]
	if who != "":
		var tw := font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var col := _tag_col(who)
		_sticker(c, Vector2(center.x - lw / 2.0 - 18.0 + (tw + 32.0) / 2.0, center.y - h / 2.0 - 4.0), Vector2(tw + 32.0, 38.0), -0.04, sb_sel)
		c.draw_set_transform(Vector2(center.x - lw / 2.0 - 18.0 + (tw + 32.0) / 2.0, center.y - h / 2.0 - 4.0), -0.04, Vector2.ONE)
		c.draw_string(font, Vector2(-tw / 2.0, 8), who, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, col)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if cs_chars >= float(full.length()) and fposmod(cs_t * 2.0, 1.0) < 0.7:
		_txt(c, "SPACE  >", Vector2(SW - 190, center.y - h / 2.0 - 16.0), 22, CREAM, 6)
	_txt(c, "N: skip", Vector2(20, 34), 18, CREAM, 6)


func _draw_cutscene() -> void:
	var c: CanvasItem = hud
	var pg: Dictionary = CUTS[cs_id][cs_page]
	var t := cs_t
	match String(pg["s"]):
		"sleep": _sc_sleep(c, t)
		"steal": _sc_steal(c, t)
		"jump": _sc_jump(c, t)
		"splat": _sc_splat(c, t)
		"hero": _sc_hero(c, t)
		"walk": _sc_walk(c, t)
		"taunt": _sc_taunt(c, t)
		"saws": _sc_saws(c, t)
		"cave": _sc_cave(c, t)
		"plan": _sc_plan(c, t)
		"shrug": _sc_shrug(c, t)
		"castle": _sc_castle(c, t)
		"laugh": _sc_laugh(c, t)
		"crack": _sc_crack(c, t)
		"cry": _sc_cry(c, t)
		"share": _sc_share(c, t)
		"end": _sc_end(c, t)
		"empty": _sc_empty(c, t)
		"note": _sc_note(c, t)
		"confess": _sc_confess(c, t)
		"farfield": _sc_farfield(c, t)
		"team": _sc_team(c, t)
		"stan": _sc_stan(c, t)
		"unmask": _sc_unmask(c, t)
		"gasp": _sc_gasp(c, t)
		"pat": _sc_pat(c, t)
		"run": _sc_run(c, t)
		"patch": _sc_patch(c, t)
		"plant": _sc_plant(c, t)
		"grow": _sc_grow(c, t)
		"farmer": _sc_farmer(c, t)
		"run2": _sc_run2(c, t)
	c.draw_rect(Rect2(5, 5, SW - 10, SH - 10), INK, false, 10.0)
	_draw_caption(c, pg)


# ---- cutscene building blocks
func _txta(c: CanvasItem, s: String, pos: Vector2, size: int, col: Color, a: float) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	col.a = a
	c.draw_string_outline(font, pos - Vector2(w / 2.0, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 10, Color(INK, a))
	c.draw_string(font, pos - Vector2(w / 2.0, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _pete(c: CanvasItem, x: float, y: float, s: float, mood: int, facing: int = 1, anim: Vector2 = Vector2.ONE, run: float = 0.0) -> void:
	PlayerScript.draw_pumpkin(c, Vector2(x, y), anim * s, facing, mood, run)


func _star(c: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + i * TAU / 10.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	_poly(c, pts, col, 2.5)


func _heart(c: CanvasItem, p: Vector2, s: float, col: Color) -> void:
	c.draw_circle(p + Vector2(-5, -3) * s, 6.5 * s + 2.5, INK)
	c.draw_circle(p + Vector2(5, -3) * s, 6.5 * s + 2.5, INK)
	_poly(c, PackedVector2Array([p + Vector2(-11.5, -1) * s, p + Vector2(11.5, -1) * s, p + Vector2(0, 12) * s]), INK, 5.0)
	c.draw_circle(p + Vector2(-5, -3) * s, 6.5 * s, col)
	c.draw_circle(p + Vector2(5, -3) * s, 6.5 * s, col)
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-11.5, -1) * s, p + Vector2(11.5, -1) * s, p + Vector2(0, 12) * s]), col)


func _rectk(c: CanvasItem, r: Rect2, fill: Color, w: float = 3.0) -> void:
	c.draw_rect(r, fill)
	c.draw_rect(r, INK, false, w)


func _draw_basket(c: CanvasItem, p: Vector2, s: float, empty: bool = false, rot: float = 0.0) -> void:
	c.draw_set_transform(p, rot, Vector2(s, s))
	if not empty:
		_disc(c, Vector2(-8, -19), 6.5, Color("e8432b"), 2.2)
		_disc(c, Vector2(3, -23), 7.5, Color("f58a1f"), 2.2)
		_disc(c, Vector2(11, -18), 6.5, Color("8cc63f"), 2.2)
	_poly(c, PackedVector2Array([Vector2(-16, -16), Vector2(16, -16), Vector2(11, 0), Vector2(-11, 0)]), Color("b8702f"), 3.5)
	c.draw_line(Vector2(-14, -10), Vector2(14, -10), Color("7a4519"), 2.5)
	c.draw_line(Vector2(-12, -4), Vector2(12, -4), Color("7a4519"), 2.5)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_crow(c: CanvasItem, p: Vector2, s: float, t: float, mood: int, facing: int = 1, flap: bool = true) -> void:
	c.draw_set_transform(p, 0.0, Vector2(s * facing, s))
	var body := Color("2e2a45")
	var lite := Color("4d4670")
	var orange := Color("ffb02e")
	_poly(c, PackedVector2Array([Vector2(-18, -2), Vector2(-48, -14), Vector2(-43, 3), Vector2(-50, 14), Vector2(-18, 12)]), body)
	for lx in [-6.0, 7.0]:
		c.draw_line(Vector2(lx, 18), Vector2(lx - 1, 34), INK, 5.0)
		c.draw_line(Vector2(lx, 18), Vector2(lx - 1, 34), orange, 2.4)
		c.draw_line(Vector2(lx - 1, 34), Vector2(lx + 7, 35), INK, 5.0)
		c.draw_line(Vector2(lx - 1, 34), Vector2(lx + 7, 35), orange, 2.4)
	_disc(c, Vector2.ZERO, 22, body, 3.0)
	c.draw_circle(Vector2(5, 7), 12, lite)
	var wa := sin(t * 11.0) * 0.6 if flap else 0.15
	var pivot := Vector2(-4, -6)
	var wp := PackedVector2Array()
	for q in [Vector2(-4, -6), Vector2(-36, -26), Vector2(-44, 4), Vector2(-16, 12)]:
		wp.append(pivot + (q - pivot).rotated(wa))
	_poly(c, wp, Color("3b3560"), 3.0)
	_disc(c, Vector2(18, -16), 15, body, 3.0)
	if mood == 3:
		var open := 5.0 + sin(t * 14.0) * 3.0
		_poly(c, PackedVector2Array([Vector2(30, -21), Vector2(53, -13 - open * 0.3), Vector2(30, -12)]), orange, 2.5)
		_poly(c, PackedVector2Array([Vector2(30, -10), Vector2(50, -4 + open), Vector2(30, -3)]), orange, 2.5)
	else:
		_poly(c, PackedVector2Array([Vector2(30, -20), Vector2(53, -11), Vector2(30, -4)]), orange, 2.5)
	c.draw_circle(Vector2(22, -20), 6.5, INK)
	c.draw_circle(Vector2(22, -20), 5.2, Color.WHITE)
	c.draw_circle(Vector2(23.5, -19.5), 2.6, INK)
	if mood == 1:
		c.draw_line(Vector2(15, -23.5), Vector2(29, -19.5), INK, 4.0)
	elif mood == 2:
		c.draw_line(Vector2(15, -26), Vector2(28, -29), INK, 3.0)
		for k in 2:
			var ph := fposmod(t * 1.3 + k * 0.5, 1.0)
			c.draw_circle(Vector2(25, -12 + ph * 34), 3.4 * (1.0 - ph * 0.4), Color("7fd4ff"))
	elif mood == 3:
		c.draw_line(Vector2(15, -26), Vector2(28, -23), INK, 3.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _cs_sky(c: CanvasItem, top: Color, bot: Color) -> void:
	for i in 18:
		c.draw_rect(Rect2(0, i * 32, SW, 33), top.lerp(bot, i / 17.0))


func _cs_hills(c: CanvasItem, base: float, col: Color, amp: float, ph: float) -> void:
	var pts := PackedVector2Array()
	for x in range(0, SW + 41, 40):
		pts.append(Vector2(x, base + sin(x * 0.009 + ph) * amp))
	var line := pts.duplicate()
	pts.append(Vector2(SW, 430))
	pts.append(Vector2(0, 430))
	c.draw_colored_polygon(pts, col)
	c.draw_polyline(line, INK, 3.0, true)


func _cs_ground(c: CanvasItem, gy: float, grass: Color, dirt: Color) -> void:
	c.draw_rect(Rect2(0, gy, SW, SH - gy), dirt)
	for i in 14:
		c.draw_circle(Vector2(30 + i * 70, gy + 34 + (i % 3) * 26), 4.0, dirt.darkened(0.18))
	c.draw_line(Vector2(0, gy), Vector2(SW, gy), INK, 6.0)
	for x in range(0, SW, 24):
		_disc(c, Vector2(x + 12, gy + 1), 9.0, grass, 2.0)
	c.draw_rect(Rect2(0, gy - 1, SW, 7), grass)


func _cs_clouds(c: CanvasItem, t: float) -> void:
	for i in 4:
		var cp := Vector2(fposmod(i * 270.0 + t * 12.0, SW + 260.0) - 130.0, 60.0 + (i * 53 % 110))
		var s := 1.0 + 0.2 * (i % 2)
		for o in [Vector2(-26, 6), Vector2(0, -6), Vector2(26, 6), Vector2(0, 8)]:
			c.draw_circle(cp + o * s, 22 * s + 3.0, INK)
		for o in [Vector2(-26, 6), Vector2(0, -6), Vector2(26, 6), Vector2(0, 8)]:
			c.draw_circle(cp + o * s, 22 * s, Color.WHITE)


func _cs_sun(c: CanvasItem, p: Vector2, t: float) -> void:
	for i in 12:
		var a := t * 0.25 + i * TAU / 12.0
		_poly(c, PackedVector2Array([p + Vector2(cos(a - 0.1), sin(a - 0.1)) * 58.0, p + Vector2(cos(a), sin(a)) * 82.0, p + Vector2(cos(a + 0.1), sin(a + 0.1)) * 58.0]), Color("ffd23f"), 3.0)
	_disc(c, p, 48, Color("ffe66b"), 3.5)
	c.draw_circle(p + Vector2(-15, -6), 4.5, INK)
	c.draw_circle(p + Vector2(15, -6), 4.5, INK)
	c.draw_arc(p + Vector2(0, 4), 18, deg_to_rad(20), deg_to_rad(160), 10, INK, 3.5)


func _bg_day(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("8fd9f6"), Color("fff1c2"))
	_cs_sun(c, Vector2(820, 100), t)
	_cs_clouds(c, t)
	_cs_hills(c, 330.0, Color("b5d86a"), 22.0, 0.0)
	_cs_hills(c, 362.0, Color("8fc24a"), 18.0, 2.0)
	_cs_ground(c, 400.0, Color("7cc23a"), Color("9a5128"))


func _bg_dusk(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("5b4a9a"), Color("ff9f5a"))
	_disc(c, Vector2(180, 150), 40, Color("ffd9a0"), 3.5)
	_cs_hills(c, 330.0, Color("6a4a8a"), 24.0, 1.0)
	_cs_hills(c, 362.0, Color("4a3a7a"), 18.0, 3.0)
	_cs_ground(c, 400.0, Color("5f8a3a"), Color("6a3a22"))


func _bg_night(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("141a3a"), Color("3f4488"))
	for i in 28:
		var tw := 0.5 + 0.5 * sin(t * 2.0 + i * 1.7)
		c.draw_circle(Vector2(fposmod(i * 137.0, SW), 20.0 + (i * 61 % 220)), 1.5 + tw * 2.2, Color(1, 0.95, 0.65, 0.5 + tw * 0.5))
	_disc(c, Vector2(120, 110), 36, Color("fff4c8"), 3.5)
	_cs_hills(c, 340.0, Color("2a2f66"), 20.0, 0.5)
	_cs_ground(c, 400.0, Color("3a5a3a"), Color("3a2a2a"))


func _bg_cave(c: CanvasItem, lit: bool) -> void:
	_cs_sky(c, Color("1c1228"), Color("4a3248") if lit else Color("2a1c34"))
	for i in 9:
		var x := 40.0 + i * 118.0
		var hgt := 60.0 + (i * 37 % 70)
		_poly(c, PackedVector2Array([Vector2(x - 28, 0), Vector2(x + 28, 0), Vector2(x, hgt)]), Color("5a4560"), 3.0)
	_cs_ground(c, 400.0, Color("6a5a6a"), Color("3a2a3a"))


func _tree(c: CanvasItem, p: Vector2, s: float, leaf: Color) -> void:
	_rectk(c, Rect2(p.x - 12 * s, p.y - 90 * s, 24 * s, 90 * s), Color("6a3a22"))
	for o in [Vector2(0, -120), Vector2(-34, -98), Vector2(34, -98)]:
		c.draw_circle(p + o * s, 42 * s + 3.0, INK)
	for o in [Vector2(0, -120), Vector2(-34, -98), Vector2(34, -98)]:
		c.draw_circle(p + o * s, 42 * s, leaf)


func _castle(c: CanvasItem, p: Vector2, s: float) -> void:
	var stone := Color("7b7490")
	var dark := Color("5a5472")
	_rectk(c, Rect2(p.x - 120 * s, p.y - 200 * s, 240 * s, 200 * s), stone, 4.0)
	for i in 6:
		_rectk(c, Rect2(p.x - 120 * s + i * 44 * s, p.y - 222 * s, 28 * s, 24 * s), stone, 3.0)
	for tx in [-150.0, 150.0]:
		_rectk(c, Rect2(p.x + (tx - 42) * s, p.y - 300 * s, 84 * s, 300 * s), dark, 4.0)
		_poly(c, PackedVector2Array([Vector2(p.x + (tx - 54) * s, p.y - 300 * s), Vector2(p.x + (tx + 54) * s, p.y - 300 * s), Vector2(p.x + tx * s, p.y - 380 * s)]), Color("c9301f"), 4.0)
		c.draw_line(Vector2(p.x + tx * s, p.y - 380 * s), Vector2(p.x + tx * s, p.y - 420 * s), INK, 4.0)
		_poly(c, PackedVector2Array([Vector2(p.x + tx * s, p.y - 420 * s), Vector2(p.x + (tx + 34) * s, p.y - 408 * s), Vector2(p.x + tx * s, p.y - 396 * s)]), Color("2e2a45"), 3.0)
		_rectk(c, Rect2(p.x + (tx - 10) * s, p.y - 240 * s, 20 * s, 36 * s), Color("2a1c34"), 3.0)
	c.draw_circle(Vector2(p.x, p.y - 80 * s), 50 * s, INK)
	c.draw_rect(Rect2(p.x - 50 * s, p.y - 80 * s, 100 * s, 80 * s), INK)
	c.draw_circle(Vector2(p.x, p.y - 80 * s), 44 * s, Color("2a1c34"))
	c.draw_rect(Rect2(p.x - 44 * s, p.y - 80 * s, 88 * s, 80 * s), Color("2a1c34"))
	for k in 6:
		var a := k * 0.9 + 0.3
		c.draw_line(Vector2(p.x - 120 * s + a * 40 * s, p.y - 190 * s), Vector2(p.x - 100 * s + a * 40 * s, p.y - 170 * s), Color("a8a2c0"), 3.0)


# ---- the scenes
func _sc_sleep(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_draw_basket(c, Vector2(650, 402), 2.2)
	var br := 1.0 + 0.035 * sin(t * 2.2)
	_pete(c, 420, 402, 3.0, 4, 1, Vector2(1.0 / br, br))
	for i in 3:
		var ph := fposmod(t * 0.6 + i * 0.33, 1.0)
		_txta(c, "Z", Vector2(490 + ph * 50 + i * 8, 290 - ph * 110), 26 + int(ph * 26), Color.WHITE, 1.0 - ph)


func _sc_steal(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	var u := clampf(t / 1.5, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	var carrying := t >= 1.5
	var cp := Vector2.ZERO
	if not carrying:
		cp = Vector2(lerpf(1100.0, 660.0, u), lerpf(110.0, 296.0, u) + sin(t * 9.0) * 8.0 * (1.0 - u))
		_draw_basket(c, Vector2(660, 402), 2.2)
	else:
		var u2 := clampf((t - 1.5) / 1.6, 0.0, 1.0)
		u2 = u2 * u2 * (3.0 - 2.0 * u2)
		cp = Vector2(lerpf(660.0, 920.0, u2), lerpf(296.0, 90.0, u2) + sin(t * 9.0) * 5.0)
		_draw_basket(c, cp + Vector2(0, 92), 1.7)
	_draw_crow(c, cp, 1.7, t, 0, 1 if carrying else -1)
	var st := maxf(0.0, 1.0 - (t - 1.5) * 4.0)
	var k := 1.0 + 0.25 * st if carrying else 1.0
	_pete(c, 330, 402, 3.0, 2 if carrying else 4, 1, Vector2(1.0 / k, k))
	if carrying:
		_txta(c, "!", Vector2(335 + sin(t * 40.0) * 3.0, 215), 70, Color("ff6b4a"), 1.0)


func _sc_jump(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	var cp := Vector2(640.0 + t * 70.0, 150.0 - t * 9.0)
	_draw_crow(c, cp, 0.9, t, 1, 1)
	_draw_basket(c, cp + Vector2(0, 52), 0.8)
	var ph := fposmod(t * 0.85, 1.0)
	var h := 4.0 * ph * (1.0 - ph) * 150.0
	var sq := Vector2(1.25, 0.75) if (ph < 0.07 or ph > 0.93) else Vector2(0.88, 1.14)
	_pete(c, 330, 402.0 - h, 3.0, 1 if h > 6.0 else 5, 1, sq)
	if ph < 0.35:
		_txta(c, "HEY!!", Vector2(330, 230.0 - ph * 40.0), 48, Color("ff6b4a"), 1.0)


func _sc_splat(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_draw_crow(c, Vector2(860.0 - t * 4.0, 70), 0.6, t, 0, 1)
	var u := clampf(t / 0.25, 0.0, 1.0)
	_pete(c, 420, 402, 3.0, 6, 1, Vector2(lerpf(1.0, 1.9, u), lerpf(1.0, 0.45, u)))
	for i in 4:
		var a := t * 3.0 + i * TAU / 4.0
		_star(c, Vector2(420.0 + cos(a) * 62.0, 345.0 + sin(a) * 14.0), 11.0, Color("ffd23f"))
	_txta(c, "SPLAT!", Vector2(600, 330.0 + sin(t * 8.0) * 3.0), 56, Color("ff6b4a"), 1.0)


func _sc_hero(c: CanvasItem, t: float) -> void:
	_sunburst(c, Vector2(SW / 2.0, 260), Color(1.0, 0.9, 0.4, 0.45))
	_wobble_word(c, "BOUNCE BACK!", SW / 2.0, 105, 72, 0)
	var ph := fposmod(t * 1.2, 1.0)
	var h := 4.0 * ph * (1.0 - ph) * 105.0
	var sq := Vector2(1.25, 0.75) if (ph < 0.08 or ph > 0.92) else Vector2(0.88, 1.14)
	_draw_pad(c, SW / 2.0, 402, maxf(0.0, 1.0 - ph * 6.0), 0.0, 2.4)
	_pete(c, SW / 2.0, 360.0 - h, 3.2, 7, 1, sq)
	if ph < 0.3:
		_txta(c, "BOING!", Vector2(SW / 2.0 + 150, 300.0 - ph * 100.0), 46, Color("f6e05a"), 1.0)


func _sc_walk(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	for i in 6:
		_tree(c, Vector2(fposmod(i * 230.0 - t * 90.0, SW + 240.0) - 120.0, 400), 1.0 + (i % 3) * 0.25, Color("3d2c6a"))
	_pete(c, 300, 402.0 - absf(sin(t * 14.0)) * 5.0, 3.0, 0, 1, Vector2.ONE, t * 14.0)


func _sc_taunt(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	_tree(c, Vector2(800, 400), 2.4, Color("3d2c6a"))
	_draw_crow(c, Vector2(740, 168.0 + sin(t * 3.0) * 4.0), 2.0, t, 1, -1, false)
	_rectk(c, Rect2(560, 300, 14, 102), Color("8a5a2a"))
	c.draw_set_transform(Vector2(567, 290), -0.08, Vector2.ONE)
	_rectk(c, Rect2(-80, -26, 160, 52), Color("c98a3a"))
	c.draw_string(font, Vector2(-66, 9), "SAWMILL >", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, INK)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_pete(c, 260, 402, 3.0, 5, 1)
	for i in 3:
		var ph := fposmod(t * 0.9 + i * 0.33, 1.0)
		c.draw_circle(Vector2(255.0 + (i - 1) * 20.0, 300.0 - ph * 80.0), 8.0 + ph * 9.0, Color(1, 1, 1, 1.0 - ph))


func _sc_saws(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	for i in 3:
		var x := fposmod(1000.0 - t * 150.0 + i * 330.0, SW + 340.0) - 170.0
		c.draw_set_transform(Vector2(x, 365), 0.0, Vector2(2.3, 2.3))
		_draw_saw(c, Vector2.ZERO, t * 10.0 + i)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_pete(c, 200.0 + sin(t * 40.0) * 2.0, 402, 3.0, 2, 1)


func _sc_cave(c: CanvasItem, t: float) -> void:
	_bg_cave(c, false)
	for r in 6:
		c.draw_circle(Vector2(270, 320), 150.0 - r * 22.0, Color(1.0, 0.9, 0.4, 0.07))
	_pete(c, 200, 402, 2.8, 2, 1)
	c.draw_line(Vector2(238, 350), Vector2(262, 322), INK, 4.0)
	_disc(c, Vector2(266, 316), 9.0, Color("ffe14a"), 2.5)
	var bob := sin(t * 2.0) * 6.0
	var blink := fposmod(t, 3.0) < 0.15
	for ex in [700.0, 760.0]:
		if blink:
			c.draw_line(Vector2(ex - 13, 250 + bob), Vector2(ex + 13, 250 + bob), Color("ffe14a"), 4.0)
		else:
			c.draw_circle(Vector2(ex, 250 + bob), 15.0, Color(1.0, 0.9, 0.3, 0.9))
			c.draw_circle(Vector2(ex - 4, 250 + bob), 5.0, INK)


func _sc_plan(c: CanvasItem, t: float) -> void:
	_bg_cave(c, true)
	_rectk(c, Rect2(380, 60, 520, 240), CREAM, 6.0)
	var lines := ["1. SPIKES", "2. MORE SPIKES", "3. ???", "4. APPLES"]
	for i in 4:
		if t > 0.6 + i * 1.0:
			c.draw_string(font, Vector2(420, 118 + i * 52), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color("c9301f") if i == 2 else INK)
	_draw_crow(c, Vector2(640, 400.0 - 34.0 * 2.0 + sin(t * 6.0) * 3.0), 2.0, t, 3, -1, false)


func _sc_shrug(c: CanvasItem, t: float) -> void:
	_bg_cave(c, true)
	_rectk(c, Rect2(260, 50, 440, 210), CREAM, 6.0)
	c.draw_string(font, Vector2(350, 190), "???", HORIZONTAL_ALIGNMENT_LEFT, -1, 110, Color("c9301f"))
	var br := 1.0 + 0.03 * sin(t * 3.0)
	_pete(c, SW / 2.0, 402, 3.2, 5, 1, Vector2(1.0 / br, br))
	_sticker_text(c, "...", Vector2(600, 270.0 + sin(t * 2.0) * 4.0), 40, 0.04)


func _sc_castle(c: CanvasItem, t: float) -> void:
	_bg_night(c, t)
	_castle(c, Vector2(640, 402), 1.0)
	_pete(c, 170, 402, 2.4, 1, 1)
	_draw_crow(c, Vector2(840.0 + sin(t) * 10.0, 120.0), 0.9, t, 1, -1)


func _sc_laugh(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("2a2438"), Color("4a3a58"))
	for y in range(0, SH, 48):
		for x in range(-40 if (y / 48) % 2 == 0 else 0, SW, 80):
			c.draw_rect(Rect2(x, y, 80, 48), Color("5a4e6e"), false, 3.0)
	c.draw_circle(Vector2(SW / 2.0, 290), 190.0, INK)
	c.draw_rect(Rect2(SW / 2.0 - 190, 290, 380, 260), INK)
	c.draw_circle(Vector2(SW / 2.0, 290), 178.0, Color("e8793a"))
	c.draw_rect(Rect2(SW / 2.0 - 178, 290, 356, 260), Color("e8793a"))
	var bob := sin(t * 10.0) * 4.0
	_draw_crow(c, Vector2(SW / 2.0 + 20.0, 330.0 + bob), 3.6, t, 3, -1, false)
	_draw_basket(c, Vector2(SW / 2.0 - 140.0, 480.0 + bob), 2.6)
	var ph := fposmod(t * 1.5, 1.0)
	_txta(c, "HA HA HA!", Vector2(SW / 2.0 + 250, 150.0 - ph * 20.0), 52, Color("ffd23f"), 1.0)


func _sc_crack(c: CanvasItem, t: float) -> void:
	_sunburst(c, Vector2(SW / 2.0, 250), Color(0.85, 0.2, 0.1, 0.45))
	var k := 1.0 + 0.05 * sin(t * 6.0)
	_pete(c, SW / 2.0, 470, 5.0, 7, 1, Vector2(k, 2.0 - k))
	for i in 6:
		var a := t * 2.0 + i * TAU / 6.0
		_star(c, Vector2(SW / 2.0 + cos(a) * 250.0, 250.0 + sin(a) * 90.0), 12.0, Color("ffd23f"))


func _sc_cry(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_draw_basket(c, Vector2(480, 402), 2.4)
	for i in 3:
		var sa := t * 2.0 + i * 2.1
		_star(c, Vector2(480.0 + cos(sa) * 50.0, 330.0 + sin(sa * 1.3) * 24.0), 8.0, Color("fff3a0"))
	_draw_crow(c, Vector2(710, 402.0 - 34.0 * 2.2 + sin(t * 4.0) * 2.0), 2.2, t, 2, -1, false)
	_pete(c, 270, 402, 3.0, 3, 1)


func _sc_share(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_draw_basket(c, Vector2(480, 402), 2.4)
	_pete(c, 330, 402.0 - absf(sin(t * 3.0)) * 8.0, 3.0, 3, 1)
	_draw_crow(c, Vector2(630, 402.0 - 34.0 * 2.0 - absf(sin(t * 3.0 + 1.0)) * 8.0), 2.0, t, 1, -1, false)
	for i in 4:
		var ph := fposmod(t * 0.5 + i * 0.25, 1.0)
		_heart(c, Vector2(400.0 + i * 55.0 + sin(ph * 6.0) * 10.0, 280.0 - ph * 150.0), 1.4, Color("ff5d7a"))


func _sc_end(c: CanvasItem, t: float) -> void:
	_sunburst(c, Vector2(SW / 2.0, 260), Color(1.0, 0.9, 0.4, 0.45))
	_wobble_word(c, "THE END", SW / 2.0, 150, 100, 2)
	var ph := fposmod(t * 1.4, 1.0)
	var ph2 := fposmod(t * 1.4 + 0.5, 1.0)
	_pete(c, 300, 430.0 - 4.0 * ph * (1.0 - ph) * 120.0, 3.0, 3, 1)
	_draw_crow(c, Vector2(680, 430.0 - 34.0 * 2.0 - 4.0 * ph2 * (1.0 - ph2) * 120.0), 2.0, t, 1, -1, false)
	var ph3 := fposmod(t * 1.4 + 0.25, 1.0)
	_draw_scarecrow(c, Vector2(490, 430.0 - 4.0 * ph3 * (1.0 - ph3) * 100.0), 1.0, t, true, 0, 1)
	for i in 40:
		var cx := fposmod(i * 97.0, SW)
		var cy := fposmod(t * 120.0 + i * 53.0, SH + 20.0) - 10.0
		var col: Color = PALETTE[i % PALETTE.size()]
		c.draw_rect(Rect2(cx, cy, 9, 14), col)
		c.draw_rect(Rect2(cx, cy, 9, 14), INK, false, 1.5)


# ---- extra characters and props (chapters 5 and 6)
func _hat(c: CanvasItem, p: Vector2, rot: float, s: float) -> void:
	c.draw_set_transform(p, rot, Vector2(s, s))
	_poly(c, PackedVector2Array([Vector2(-24, 0), Vector2(24, 0), Vector2(18, -26), Vector2(-18, -26)]), Color("e8c45a"), 3.5)
	c.draw_rect(Rect2(-22, -9, 44, 8), Color("c9301f"))
	_poly(c, PackedVector2Array([Vector2(-46, 0), Vector2(46, 0), Vector2(38, 9), Vector2(-38, 9)]), Color("d9a93e"), 3.5)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## p = bottom of the pole. mood: 0 calm, 1 evil (glowing eyes), 2 sad/shocked.
func _draw_scarecrow(c: CanvasItem, p: Vector2, s: float, t: float, hat_off: bool = false, mood: int = 0, facing: int = 1) -> void:
	c.draw_set_transform(p, 0.0, Vector2(s * facing, s))
	_rectk(c, Rect2(-5, -150, 10, 150), Color("8a5a2a"), 3.0)
	_rectk(c, Rect2(-62, -112, 124, 12), Color("8a5a2a"), 3.0)
	for sx in [-1.0, 1.0]:
		for k in 5:
			var a: float = deg_to_rad(-30.0 + k * 15.0) * float(sx) + (PI if sx < 0 else 0.0)
			var from := Vector2(sx * 62.0, -106.0)
			var to := from + Vector2(cos(a), sin(a)) * 24.0
			c.draw_line(from, to, INK, 5.0)
			c.draw_line(from, to, Color("f0cf5a"), 2.5)
	_poly(c, PackedVector2Array([Vector2(-30, -118), Vector2(30, -118), Vector2(24, -60), Vector2(-24, -60)]), Color("4a78c2"), 3.5)
	c.draw_rect(Rect2(-8, -100, 15, 15), Color("e8432b"))
	c.draw_rect(Rect2(-8, -100, 15, 15), INK, false, 2.0)
	for k in 6:
		c.draw_line(Vector2(-20 + k * 8, -60), Vector2(-24 + k * 9, -48), INK, 4.0)
		c.draw_line(Vector2(-20 + k * 8, -60), Vector2(-24 + k * 9, -48), Color("f0cf5a"), 2.0)
	_disc(c, Vector2(0, -150), 28, Color("ee9a40"), 3.5)
	c.draw_arc(Vector2(0, -150), 17, deg_to_rad(105), deg_to_rad(255), 10, Color("c75a14"), 2.5)
	c.draw_arc(Vector2(0, -150), 17, deg_to_rad(-75), deg_to_rad(75), 10, Color("c75a14"), 2.5)
	var eye := Color("ffe14a") if mood == 1 else INK
	_poly(c, PackedVector2Array([Vector2(-17, -162), Vector2(-5, -162), Vector2(-11, -150)]), eye, 2.5)
	_poly(c, PackedVector2Array([Vector2(5, -162), Vector2(17, -162), Vector2(11, -150)]), eye, 2.5)
	var mp := PackedVector2Array([Vector2(-14, -139), Vector2(-8, -133), Vector2(-3, -139), Vector2(3, -133), Vector2(8, -139), Vector2(14, -133)])
	if mood == 2:
		mp = PackedVector2Array([Vector2(-12, -131), Vector2(-6, -137), Vector2(0, -131), Vector2(6, -137), Vector2(12, -131)])
		for k in 2:
			var ph := fposmod(t * 1.3 + k * 0.5, 1.0)
			c.draw_circle(Vector2(-11 + k * 22.0, -146 + ph * 40.0), 3.6, Color("7fd4ff"))
	c.draw_polyline(mp, INK, 3.5, true)
	if hat_off:
		_poly(c, PackedVector2Array([Vector2(-4, -176), Vector2(4, -176), Vector2(3, -190), Vector2(-3, -190)]), Color("5f9a2a"), 3.0)
		_poly(c, PackedVector2Array([Vector2(3, -184), Vector2(14, -192), Vector2(11, -180)]), Color("86c240"), 2.5)
	else:
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_hat(c, p + Vector2(0, -174.0 * s), 0.0, s)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_farmer(c: CanvasItem, p: Vector2, s: float, t: float) -> void:
	c.draw_set_transform(p, 0.0, Vector2(s, s))
	_rectk(c, Rect2(-24, -70, 20, 70), Color("3a4a8a"), 3.5)
	_rectk(c, Rect2(4, -70, 20, 70), Color("3a4a8a"), 3.5)
	_rectk(c, Rect2(-34, -150, 68, 86), Color("4f68b8"), 3.5)
	_rectk(c, Rect2(-34, -150, 68, 26), Color("e8432b"), 3.5)
	_disc(c, Vector2(0, -178), 28, Color("f2c49b"), 3.5)
	c.draw_circle(Vector2(-10, -183), 3.6, INK)
	c.draw_circle(Vector2(10, -183), 3.6, INK)
	c.draw_arc(Vector2(0, -172), 12, deg_to_rad(20), deg_to_rad(160), 8, INK, 3.0)
	_poly(c, PackedVector2Array([Vector2(-13, -171), Vector2(0, -175), Vector2(13, -171), Vector2(0, -166)]), Color("5a3a1a"), 2.5)
	_poly(c, PackedVector2Array([Vector2(-40, -196), Vector2(40, -196), Vector2(30, -186), Vector2(-30, -186)]), Color("d9a93e"), 3.5)
	_poly(c, PackedVector2Array([Vector2(-22, -196), Vector2(22, -196), Vector2(16, -224), Vector2(-16, -224)]), Color("e8c45a"), 3.5)
	_disc(c, Vector2(-44 + sin(t * 4.0) * 2.0, -110), 28, Color("f2d9a0"), 3.5)
	_disc(c, Vector2(-44 + sin(t * 4.0) * 2.0, -112), 20, Color("f58a1f"), 2.5)
	for k in 4:
		c.draw_line(Vector2(-54 + k * 7, -122), Vector2(-52 + k * 7, -104), Color("c75a14"), 2.5)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _windmill(c: CanvasItem, p: Vector2, s: float, t: float) -> void:
	_poly(c, PackedVector2Array([p + Vector2(-50, 0) * s, p + Vector2(50, 0) * s, p + Vector2(30, -190) * s, p + Vector2(-30, -190) * s]), Color("d9c49a"), 4.0)
	_poly(c, PackedVector2Array([p + Vector2(-42, -190) * s, p + Vector2(42, -190) * s, p + Vector2(0, -240) * s]), Color("c9301f"), 4.0)
	var hub := p + Vector2(0, -196) * s
	for i in 4:
		var a := t * 0.8 + i * PI / 2.0
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x)
		_poly(c, PackedVector2Array([hub + d * 14.0 * s + n * 5.0 * s, hub + d * 150.0 * s + n * 16.0 * s, hub + d * 150.0 * s - n * 6.0 * s, hub + d * 14.0 * s - n * 5.0 * s]), Color("fff3cf"), 3.5)
	_disc(c, hub, 9.0 * s, Color("8a5a2a"), 3.0)


func _giant_pumpkin(c: CanvasItem, p: Vector2, s: float) -> void:
	var cen := p + Vector2(0, -150.0 * s)
	c.draw_set_transform(cen, 0.0, Vector2(1.15, 0.9))
	c.draw_circle(Vector2.ZERO, 170.0 * s + 5.0, INK)
	c.draw_circle(Vector2.ZERO, 170.0 * s, Color("f58a1f"))
	for sx in [-1.0, 1.0]:
		for pr in [[60.0, 30.0], [120.0, 22.0]]:
			var xt: float = pr[0]
			var span: float = pr[1]
			var rr := 230.0 * s
			var ctr := Vector2(sx * (xt * s + rr), 0.0)
			var a0 := 180.0 - span if sx > 0 else -span
			var a1 := 180.0 + span if sx > 0 else span
			c.draw_arc(ctr, rr, deg_to_rad(a0), deg_to_rad(a1), 16, Color("c75a14"), 4.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_poly(c, PackedVector2Array([cen + Vector2(-16, -135) * s, cen + Vector2(16, -135) * s, cen + Vector2(10, -190) * s, cen + Vector2(-10, -190) * s]), Color("5f9a2a"), 4.0)
	_poly(c, PackedVector2Array([cen + Vector2(10, -170) * s, cen + Vector2(60, -200) * s, cen + Vector2(44, -150) * s]), Color("86c240"), 3.5)
	c.draw_circle(cen + Vector2(0, 120) * s, 62.0 * s, INK)
	c.draw_rect(Rect2(cen + Vector2(-62, 120) * s, Vector2(124, 30) * s), INK)
	c.draw_circle(cen + Vector2(0, 120) * s, 54.0 * s, Color("5a2f14"))
	c.draw_rect(Rect2(cen + Vector2(-54, 120) * s, Vector2(108, 30) * s), Color("5a2f14"))
	_disc(c, cen + Vector2(-80, -10) * s, 26.0 * s, Color("ffe66b"), 4.0)
	_disc(c, cen + Vector2(80, -10) * s, 26.0 * s, Color("ffe66b"), 4.0)


func _bg_corn(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("141a3a"), Color("5a3a6a"))
	_disc(c, Vector2(820, 100), 34, Color("fff4c8"), 3.5)
	for i in 22:
		var tw := 0.5 + 0.5 * sin(t * 2.0 + i * 1.7)
		c.draw_circle(Vector2(fposmod(i * 151.0, SW), 20.0 + (i * 67 % 200)), 1.5 + tw * 2.0, Color(1, 0.95, 0.65, 0.5 + tw * 0.5))
	_cs_hills(c, 345.0, Color("2a2f55"), 18.0, 0.5)
	_cs_ground(c, 400.0, Color("4a6a3a"), Color("3a2a22"))
	for i in 38:
		var x := i * 26.0 + (i % 3) * 5.0
		var h := 60.0 + (i * 13 % 34)
		c.draw_line(Vector2(x, 400), Vector2(x, 400.0 - h), INK, 6.0)
		c.draw_line(Vector2(x, 400), Vector2(x, 400.0 - h), Color("7ea83a"), 3.0)
		_poly(c, PackedVector2Array([Vector2(x, 400.0 - h * 0.5), Vector2(x + 16, 400.0 - h * 0.8), Vector2(x + 3, 400.0 - h * 0.35)]), Color("8cc63f"), 2.0)
		_disc(c, Vector2(x - 1, 400.0 - h - 6.0), 5.0, Color("f2c94c"), 2.0)


# ---- the chapter 5 and 6 scenes
func _sc_empty(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_draw_basket(c, Vector2(500, 402), 2.6, true, -0.5)
	_disc(c, Vector2(590, 388), 13, Color("e8432b"), 2.5)
	_disc(c, Vector2(640, 392), 12, Color("8cc63f"), 2.5)
	var k := 1.0 + 0.04 * sin(t * 6.0)
	_pete(c, 280, 402, 3.0, 2, 1, Vector2(1.0 / k, k))
	_draw_crow(c, Vector2(780, 402.0 - 34.0 * 2.0), 2.0, t, 2, -1, false)
	for i in 3:
		var sa := t * 2.5 + i * 2.1
		_star(c, Vector2(480.0 + cos(sa) * 60.0, 360.0 + sin(sa * 1.3) * 16.0), 8.0, Color("ffe14a"))
	_txta(c, "?!", Vector2(285, 225), 64, Color("ffd23f"), 1.0)


func _sc_note(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("ffe8b0"), Color("f6c97a"))
	c.draw_set_transform(Vector2(480, 230), sin(t * 1.5) * 0.03 - 0.04, Vector2.ONE)
	_rectk(c, Rect2(-270, -150, 540, 300), Color("fffaf0"), 6.0)
	c.draw_string(font, Vector2(-230, -55), "THANKS FOR THE APPLES!", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, INK)
	c.draw_string(font, Vector2(-230, 15), "NO REFUNDS.", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color("c9301f"))
	c.draw_string(font, Vector2(90, 100), "- S", HORIZONTAL_ALIGNMENT_LEFT, -1, 60, INK)
	for tx in [-260.0, 230.0]:
		c.draw_rect(Rect2(tx, -164, 44, 24), Color(1, 0.95, 0.7, 0.8))
		c.draw_rect(Rect2(tx, -164, 44, 24), INK, false, 2.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sc_confess(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	_pete(c, 320, 402, 3.2, 5, 1)
	for i in 3:
		var ph := fposmod(t * 0.9 + i * 0.33, 1.0)
		c.draw_circle(Vector2(315.0 + (i - 1) * 22.0, 300.0 - ph * 80.0), 8.0 + ph * 9.0, Color(1, 1, 1, 1.0 - ph))
	_draw_crow(c, Vector2(650.0 + sin(t * 22.0) * 2.0, 402.0 - 34.0 * 2.2), 2.2, t, 2, -1, false)
	_txta(c, "GULP!", Vector2(640, 215), 46, Color.WHITE, 1.0)


func _sc_farfield(c: CanvasItem, t: float) -> void:
	_bg_corn(c, t)
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	for r in 5:
		c.draw_circle(Vector2(640, 262), 90.0 - r * 14.0 + pulse * 8.0, Color(1.0, 0.85, 0.2, 0.08))
	_draw_scarecrow(c, Vector2(740, 402), 1.0, t, false, 1, -1)
	_disc(c, Vector2(650, 280), 11, Color("ffd23f"), 3.0)
	_star(c, Vector2(650, 280), 8, Color("fff3a0"))
	_pete(c, 170, 402, 2.4, 1, 1)
	_draw_crow(c, Vector2(280, 402.0 - 34.0 * 1.6), 1.6, t, 2, 1, false)


func _sc_team(c: CanvasItem, t: float) -> void:
	_bg_day(c, t)
	var u := clampf(t / 1.2, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	var hop := absf(sin(t * 5.0)) * 14.0 * (1.0 - u)
	_pete(c, lerpf(230.0, 420.0, u), 402.0 - hop, 3.0, 3, 1)
	_draw_crow(c, Vector2(lerpf(740.0, 560.0, u), 402.0 - 34.0 * 2.0 - hop), 2.0, t, 1, -1, false)
	if u >= 1.0:
		var ph := fposmod(t * 2.0, 1.0)
		for i in 6:
			var a := i * TAU / 6.0 + t
			_star(c, Vector2(490.0 + cos(a) * (30.0 + ph * 50.0), 330.0 + sin(a) * (24.0 + ph * 40.0)), 10.0, Color("ffd23f"))
		_txta(c, "TEAM UP!", Vector2(490, 215), 52, Color("f6e05a"), 1.0)


func _sc_stan(c: CanvasItem, t: float) -> void:
	_bg_corn(c, t)
	_windmill(c, Vector2(820, 402), 1.2, t)
	_draw_scarecrow(c, Vector2(640, 402), 1.5, t, false, 1, -1)
	_pete(c, 150, 402, 2.4, 5, 1)
	_draw_crow(c, Vector2(270, 402.0 - 34.0 * 1.5), 1.5, t, 2, 1, false)


func _sc_unmask(c: CanvasItem, t: float) -> void:
	_bg_corn(c, t)
	_windmill(c, Vector2(820, 402), 1.2, t)
	var off := t > 0.5
	_draw_scarecrow(c, Vector2(640, 402), 1.5, t, off, 2 if off else 1, -1)
	if t > 0.5:
		var u := clampf((t - 0.5) / 1.2, 0.0, 1.0)
		_hat(c, Vector2(640.0 - 160.0 * u, 402.0 - 270.0 - sin(u * PI) * 130.0 + u * 140.0), t * 9.0, 1.5)
	_pete(c, 150, 402, 2.4, 2, 1)
	_draw_crow(c, Vector2(270, 402.0 - 34.0 * 1.5), 1.5, t, 2, 1, false)
	if t > 1.0:
		_txta(c, "!!", Vector2(155, 262), 60, Color("ffd23f"), 1.0)


func _sc_gasp(c: CanvasItem, t: float) -> void:
	_cs_sky(c, Color("2a2438"), Color("5a3a58"))
	_sunburst(c, Vector2(SW / 2.0, 250), Color(0.5, 0.2, 0.5, 0.35))
	_pete(c, 250.0 + sin(t * 40.0) * 3.0, 432, 4.0, 2, 1)
	_draw_scarecrow(c, Vector2(740, 560), 2.7, t, true, 2, -1)
	_wobble_word(c, "TWINS?!", SW / 2.0, 105, 64, 1)
	if fposmod(t, 2.0) < 0.12:
		c.draw_rect(Rect2(0, 0, SW, SH), Color(1, 1, 1, 0.55))


func _sc_pat(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	_draw_scarecrow(c, Vector2(480, 402), 2.0, t, true, 2, 1)
	for i in 70:
		var rx := fposmod(i * 53.0, SW)
		var ry := fposmod(t * 420.0 + i * 37.0, SH + 20.0) - 10.0
		c.draw_line(Vector2(rx, ry), Vector2(rx - 3, ry + 14), Color(0.7, 0.85, 1.0, 0.55), 2.0)


func _sc_run(c: CanvasItem, t: float) -> void:
	_bg_corn(c, t)
	var x := lerpf(560.0, 1250.0, clampf(t / 3.0, 0.0, 1.0))
	var hop := absf(sin(t * 7.0)) * 40.0
	for i in 5:
		c.draw_line(Vector2(x - 120.0 - i * 40.0, 330.0 + i * 10.0), Vector2(x - 190.0 - i * 40.0, 330.0 + i * 10.0), Color(1, 1, 1, 0.6 - i * 0.1), 4.0)
	_draw_scarecrow(c, Vector2(x, 402.0 - hop), 1.4, t, true, 1, 1)
	_disc(c, Vector2(x + 28.0, 300.0 - hop), 10, Color("ffd23f"), 3.0)
	_pete(c, 180, 402, 2.6, 5, 1)
	_draw_crow(c, Vector2(310, 402.0 - 34.0 * 1.6), 1.6, t, 2, 1, false)


func _patch_cast(c: CanvasItem, t: float) -> void:
	for row in 3:
		for i in 15:
			var px := i * 70.0 + row * 28.0 - 10.0
			var py := 428.0 + row * 34.0
			var r := 13.0 + row * 4.0
			_disc(c, Vector2(px, py), r, Color("f58a1f"), 2.5)
			c.draw_rect(Rect2(px - 2, py - r - 7, 4, 8), Color("5f9a2a"))
	_draw_scarecrow(c, Vector2(540, 402), 1.2, t, true, 0, -1)
	_pete(c, 320, 402, 2.6, 0, 1)
	_draw_crow(c, Vector2(720, 402.0 - 34.0 * 1.8), 1.8, t, 1, -1, false)
	c.draw_set_transform(Vector2(430, 404), 0.0, Vector2(1.0, 0.4))
	_disc(c, Vector2.ZERO, 36, Color("6a3a22"), 3.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sc_patch(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	_patch_cast(c, t)
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	for r in 4:
		c.draw_circle(Vector2(430, 392), 40.0 - r * 8.0 + pulse * 5.0, Color(1.0, 0.85, 0.2, 0.12))
	_disc(c, Vector2(430, 392), 10, Color("ffd23f"), 3.0)


func _sc_plant(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	_patch_cast(c, t)
	var u := clampf(t / 1.2, 0.0, 1.0)
	if t < 1.4:
		_disc(c, Vector2(430, lerpf(300.0, 396.0, u)), 10, Color("ffd23f"), 3.0)
	else:
		var g := minf((t - 1.4) * 40.0, 70.0)
		c.draw_line(Vector2(430, 398), Vector2(430, 398.0 - g), INK, 8.0)
		c.draw_line(Vector2(430, 398), Vector2(430, 398.0 - g), Color("7fbf3a"), 4.0)
		if g > 30.0:
			_poly(c, PackedVector2Array([Vector2(430, 398.0 - g * 0.6), Vector2(462, 398.0 - g * 0.9), Vector2(436, 398.0 - g * 0.35)]), Color("8cc63f"), 2.5)
			_poly(c, PackedVector2Array([Vector2(430, 398.0 - g * 0.7), Vector2(398, 398.0 - g), Vector2(424, 398.0 - g * 0.4)]), Color("8cc63f"), 2.5)
		for i in 6:
			var a := t * 2.0 + i * TAU / 6.0
			_star(c, Vector2(430.0 + cos(a) * 60.0, 340.0 + sin(a) * 36.0), 8.0, Color("fff3a0"))


func _sc_grow(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	var u := clampf(t / 2.2, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	_giant_pumpkin(c, Vector2(660, 402), 0.12 + 0.88 * u)
	_pete(c, 150, 402, 2.4, 3, 1)
	_draw_scarecrow(c, Vector2(250, 402), 1.0, t, true, 0, 1)
	_draw_crow(c, Vector2(340, 402.0 - 34.0 * 1.5 - absf(sin(t * 4.0)) * 10.0), 1.5, t, 1, 1, false)
	if u < 1.0:
		for i in 6:
			var a := t * 3.0 + i * TAU / 6.0
			_star(c, Vector2(660.0 + cos(a) * 160.0 * u, 300.0 + sin(a) * 90.0 * u), 9.0, Color("fff3a0"))


func _sc_farmer(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	_giant_pumpkin(c, Vector2(190, 402), 0.78)
	var u := clampf(t / 1.3, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	_draw_farmer(c, Vector2(lerpf(1150.0, 790.0, u), 402), 1.5, t)
	var shake := sin(t * 40.0) * 2.0 if t > 1.3 else 0.0
	_pete(c, 440.0 + shake, 402, 2.4, 2, 1)
	_draw_scarecrow(c, Vector2(540.0 + shake, 402), 1.0, t, true, 2, 1)
	_draw_crow(c, Vector2(640.0 + shake, 402.0 - 34.0 * 1.5), 1.5, t, 2, 1, false)
	if t > 1.3:
		_txta(c, "MMM... PIE!", Vector2(790, 90), 48, Color("ffd23f"), 1.0)


func _sc_run2(c: CanvasItem, t: float) -> void:
	_bg_dusk(c, t)
	var base := fposmod(t * 250.0, SW + 700.0) - 350.0
	_draw_farmer(c, Vector2(base - 420.0, 402), 1.4, t)
	_draw_crow(c, Vector2(base - 100.0, 200.0 + sin(t * 5.0) * 20.0), 1.5, t, 1, 1)
	_draw_scarecrow(c, Vector2(base + 30.0, 402.0 - absf(sin(t * 7.0)) * 40.0), 1.0, t, true, 0, 1)
	var ph := fposmod(t * 1.6, 1.0)
	var sq := Vector2(1.25, 0.75) if (ph < 0.08 or ph > 0.92) else Vector2(0.88, 1.14)
	_pete(c, base + 150.0, 402.0 - 4.0 * ph * (1.0 - ph) * 90.0, 2.6, 1, 1, sq)
	for i in 5:
		c.draw_line(Vector2(base - 40.0 - i * 30.0, 340.0 + i * 14.0), Vector2(base - 110.0 - i * 30.0, 340.0 + i * 14.0), Color(1, 1, 1, 0.5 - i * 0.08), 4.0)
