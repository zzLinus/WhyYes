extends KinematicBody2D

onready var lifeTime = $Lifetime
onready var animSprite = $AnimatedSprite
onready var hitbox = $Magic/CollisionShape2D

var activAnim = ["fireball", "fireenergy", "iceball"]
var deactivAnim = ["fireballDestroy", "fireenergyDestroy", "iceballDestroy"]

var speed: int = 150
var velocity := Vector2(0, 1)
var magicType: int
var isColli: bool = false
var lifetime: float


func _ready():
	lifetime = get_parent().lifetime
	lifeTime.wait_time = lifetime
	magicType = get_parent().magicType
	animSprite.play(activAnim[magicType])
	lifeTime.start()


func _process(delta):
	if !isColli:
		if lifeTime.is_stopped() != true:
			move_and_collide(speed * velocity * delta)
		else:
			hitbox.disabled = true
			animSprite.play(deactivAnim[magicType])
			yield(animSprite, "animation_finished")
			queue_free()
	else:
		pass


func _on_Magic_body_entered(body: Node):
	isColli = true
	hitbox.disabled = true
	animSprite.play(deactivAnim[magicType])
	yield(animSprite, "animation_finished")
	queue_free()
