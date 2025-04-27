extends Area2D
@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2
var follow = PathFollow2D.new()
var target = null
func _ready():
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false
	
func _physics_process(delta):
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	self.show()
	if follow.progress_ratio >= 1:
		queue_free()

func _on_gun_cooldown_timeout() -> void:
	if $Sprite2D.frame == 0:
		shoot()
	elif $Sprite2D.frame == 1:
		shoot_pulse(2, 0.25)
	elif $Sprite2D.frame == 2:
		shoot_pulse(3, 0.10)

func shoot():
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)

func shoot_pulse(n, delay):
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout
		
func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
		
func take_damage_rock(amount):
	if $RockDamageTimer.time_left > 0:
		return
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
	$RockDamageTimer.start(0.5)

func explode():
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks"):
		take_damage_rock(1)
		body.explode()
	if body.is_in_group("player"):
		body.shield -= 50
		explode()
