extends Area2D
@export var speed = 1000
@export var damage = 15
func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()
	
func _process(delta):
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func _on_bullet_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
	if body.is_in_group("player"):
		body.shield -= damage
		queue_free()
