extends CharacterBody2D
## The little pumpkin you control. Hitbox is 20x26, origin = centre of the box.

signal jumped
signal landed

const SPEED := 210.0
const GRAVITY := 1500.0
const JUMP_VELOCITY := -470.0
const MAX_FALL := 900.0
const INK := Color("2b1209")

## Cosmetics shared by the player, menus and cutscenes.
static var hat := 0         # 0 none, 1 party, 2 top hat, 3 propeller, 4 halo, 5 crown
static var gold := false    # golden pumpkin (secret collectible)

var alive := false
var bouncing := false      # true while rising from a pad (disables variable-jump cut)
var coyote := 0.0
var buf := 0.0             # jump buffer timer
var facing := 1
var squash := Vector2.ONE
var was_on_floor := false
var t := 0.0


func _ready() -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 26)
	cs.shape = shape
	add_child(cs)


func _physics_process(delta: float) -> void:
	t += delta
	if not alive:
		queue_redraw()
		return

	var dir := Input.get_axis("left", "right")
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1
	var rate := 0.0
	if dir != 0.0:
		rate = 1800.0 if is_on_floor() else 1300.0
	else:
		rate = 1600.0 if is_on_floor() else 500.0
	velocity.x = move_toward(velocity.x, dir * SPEED, rate * delta)

	if is_on_floor():
		coyote = 0.1
	else:
		coyote -= delta
	if Input.is_action_just_pressed("jump"):
		buf = 0.12
	else:
		buf -= delta

	if velocity.y < 0.0 and not Input.is_action_pressed("jump") and not bouncing:
		velocity.y += GRAVITY * 2.2 * delta
	else:
		velocity.y += GRAVITY * delta
	velocity.y = minf(velocity.y, MAX_FALL)

	if buf > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		buf = 0.0
		coyote = 0.0
		squash = Vector2(0.75, 1.3)
		jumped.emit()

	move_and_slide()

	if bouncing and velocity.y >= 0.0:
		bouncing = false
	if is_on_floor() and not was_on_floor:
		squash = Vector2(1.3, 0.7)
		landed.emit()
	was_on_floor = is_on_floor()

	squash = squash.lerp(Vector2.ONE, minf(1.0, 12.0 * delta))
	queue_redraw()


func _draw() -> void:
	var mood := 0
	if not is_on_floor():
		mood = 1 if velocity.y < 0.0 else 2
	var run_t := 0.0
	if is_on_floor() and absf(velocity.x) > 20.0:
		run_t = t * 16.0
	draw_pumpkin(self, Vector2(0, 13), squash, facing, mood, run_t)


## Shared cartoon pumpkin. origin = position of its feet. mood: 0 calm, 1 wheee, 2 scared, 3 happy, 4 asleep, 5 angry, 6 sad, 7 determined.
static func draw_pumpkin(c: CanvasItem, origin: Vector2, squash: Vector2, facing: int, mood: int, run_t: float) -> void:
	var orange := Color("f6c935") if gold else Color("f58a1f")
	var dark := Color("c79a14") if gold else Color("c75a14")
	c.draw_set_transform(origin, 0.0, squash)
	# boots
	var sw := sin(run_t) * 3.0
	var lf := Vector2(-5.0 + sw * 0.6, -2.5 - maxf(0.0, sw))
	var rf := Vector2(5.0 - sw * 0.6, -2.5 - maxf(0.0, -sw))
	for f in [lf, rf]:
		c.draw_circle(f, 5.0, INK)
		c.draw_circle(f, 3.4, Color("8a4b1c"))
	# body
	c.draw_circle(Vector2(0, -13), 14.0, INK)
	c.draw_circle(Vector2(0, -13), 12.2, orange)
	c.draw_arc(Vector2(0, -13), 7.0, deg_to_rad(105), deg_to_rad(255), 12, dark, 2.0)
	c.draw_arc(Vector2(0, -13), 7.0, deg_to_rad(-75), deg_to_rad(75), 12, dark, 2.0)
	c.draw_arc(Vector2(-3, -17), 6.5, deg_to_rad(190), deg_to_rad(265), 8, Color(1, 1, 1, 0.5), 2.5)
	# stem + leaf
	var stem := PackedVector2Array([Vector2(-3.2, -24), Vector2(3.2, -24), Vector2(2.4, -32), Vector2(-2.4, -32)])
	c.draw_colored_polygon(stem, Color("5f9a2a"))
	var so := stem.duplicate()
	so.append(stem[0])
	c.draw_polyline(so, INK, 2.2, true)
	var leaf := PackedVector2Array([Vector2(2.5, -29), Vector2(11, -34), Vector2(9, -26)])
	c.draw_colored_polygon(leaf, Color("86c240"))
	var lo := leaf.duplicate()
	lo.append(leaf[0])
	c.draw_polyline(lo, INK, 2.0, true)
	# eyes
	var f := float(facing)
	for sx in [-4.6, 4.6]:
		var ec := Vector2(sx + f * 1.4, -15.5)
		if mood == 4:
			c.draw_arc(ec + Vector2(0, -1.5), 3.4, deg_to_rad(15), deg_to_rad(165), 8, INK, 2.4)
		else:
			c.draw_circle(ec, 4.2, INK)
			c.draw_circle(ec, 3.3, Color.WHITE)
			var py := -0.8 if mood == 2 else 0.6
			c.draw_circle(ec + Vector2(f * 1.2, py), 1.8, INK)
	if mood == 5 or mood == 7:
		c.draw_line(Vector2(-9.5, -22.5), Vector2(-1.5, -19.5), INK, 2.8)
		c.draw_line(Vector2(9.5, -22.5), Vector2(1.5, -19.5), INK, 2.8)
	elif mood == 6:
		c.draw_line(Vector2(-9.5, -19.5), Vector2(-1.5, -22.5), INK, 2.4)
		c.draw_line(Vector2(9.5, -19.5), Vector2(1.5, -22.5), INK, 2.4)
		c.draw_circle(Vector2(-8.5, -10.5), 2.0, Color("7fd4ff"))
		c.draw_circle(Vector2(8.5, -10.5), 2.0, Color("7fd4ff"))
	# cheeks
	c.draw_circle(Vector2(-8.5, -9.5), 2.4, Color(1, 0.4, 0.45, 0.6))
	c.draw_circle(Vector2(8.5, -9.5), 2.4, Color(1, 0.4, 0.45, 0.6))
	# mouth
	var mc := Vector2(f * 1.2, -9.0)
	if mood == 1 or mood == 3:
		c.draw_circle(mc, 3.2, INK)
		c.draw_circle(mc + Vector2(0, 1.0), 1.7, Color("ff7a8a"))
	elif mood == 2:
		c.draw_circle(mc + Vector2(0, 0.5), 3.5, INK)
	elif mood == 4:
		c.draw_circle(mc + Vector2(0, 0.5), 1.9, INK)
	elif mood == 5 or mood == 6:
		c.draw_arc(mc + Vector2(0, 2.5), 3.6, deg_to_rad(205), deg_to_rad(335), 8, INK, 1.9)
	elif mood == 7:
		c.draw_arc(mc + Vector2(0, -2.0), 4.6, deg_to_rad(15), deg_to_rad(165), 10, INK, 2.2)
	else:
		c.draw_arc(mc + Vector2(0, -1.5), 3.4, deg_to_rad(25), deg_to_rad(155), 8, INK, 1.9)
	_draw_hat(c)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _outlined(c: CanvasItem, pts: PackedVector2Array, fill: Color) -> void:
	c.draw_colored_polygon(pts, fill)
	var o := pts.duplicate()
	o.append(pts[0])
	c.draw_polyline(o, INK, 2.0, true)


static func _draw_hat(c: CanvasItem) -> void:
	if hat == 1:   # party hat
		_outlined(c, PackedVector2Array([Vector2(-7, -26), Vector2(7, -26), Vector2(1, -45)]), Color("e8432b"))
		c.draw_line(Vector2(-4.2, -32), Vector2(3.6, -32), Color("f6e05a"), 2.4)
		c.draw_line(Vector2(-2.2, -38), Vector2(2.2, -38), Color("f6e05a"), 2.0)
		c.draw_circle(Vector2(1, -45.5), 3.0, INK)
		c.draw_circle(Vector2(1, -45.5), 1.9, Color("8cc63f"))
	elif hat == 2:   # top hat
		_outlined(c, PackedVector2Array([Vector2(-6.5, -29), Vector2(6.5, -29), Vector2(6.0, -45), Vector2(-6.0, -45)]), Color("3a2a2a"))
		c.draw_rect(Rect2(-6.4, -35, 12.8, 3.6), Color("e8432b"))
		_outlined(c, PackedVector2Array([Vector2(-11, -29), Vector2(11, -29), Vector2(11, -26), Vector2(-11, -26)]), Color("3a2a2a"))
	elif hat == 3:   # propeller beanie
		var dome := PackedVector2Array()
		for k in 13:
			var a := deg_to_rad(180.0 + k * 15.0)
			dome.append(Vector2(cos(a) * 9.5, -26.0 + sin(a) * 9.5))
		_outlined(c, dome, Color("3fb6c9"))
		c.draw_line(Vector2(0, -35.5), Vector2(0, -26), Color("f6c935"), 2.0)
		var sp := sin(Time.get_ticks_msec() / 45.0)
		c.draw_line(Vector2(-9.0 * sp, -39), Vector2(9.0 * sp, -39), INK, 4.2)
		c.draw_line(Vector2(-9.0 * sp, -39), Vector2(9.0 * sp, -39), Color("e8432b"), 2.2)
		c.draw_circle(Vector2(0, -36), 2.0, INK)
	elif hat == 4:   # halo
		var by := -41.0 + sin(Time.get_ticks_msec() / 260.0) * 1.5
		c.draw_arc(Vector2(0, by), 8.0, 0.0, TAU, 20, INK, 5.0)
		c.draw_arc(Vector2(0, by), 8.0, 0.0, TAU, 20, Color("ffe36a"), 2.6)
	elif hat == 5:   # crown
		_outlined(c, PackedVector2Array([Vector2(-8, -26), Vector2(-8, -38), Vector2(-4, -32), Vector2(0, -41), Vector2(4, -32), Vector2(8, -38), Vector2(8, -26)]), Color("f6c935"))
		c.draw_circle(Vector2(0, -30.5), 1.7, Color("e8432b"))
		c.draw_circle(Vector2(-4.8, -29.5), 1.2, Color("3fb6c9"))
		c.draw_circle(Vector2(4.8, -29.5), 1.2, Color("8cc63f"))
