extends KinematicBody2D

var enemyHealth: int
var playerPos : Vector2
var isAttain : bool = false
var isLookLeft : bool = true
var enemyVelocity : Vector2 = Vector2(0 ,0)
var transformer = Transform2D()
var interrupCD : float = 2.5

export(bool) var doingAction
export(PackedScene) var playerHitEffect: PackedScene
export(PackedScene) var blood: PackedScene


enum enemyState { IDLE, GETHIT, ATTACK ,RUN , TURN }


onready var animTree = $AnimationTree
onready var hitBox = $EnemyAttack/CollisionPolygon2D
onready var bladeSound = $BladeSound
onready var cameraShake = get_node("../Player/Camera2D/Node")
onready var hurtSound = $Hurt
onready var attainSprite = $enemyAttaintion
onready var animSprite = $AnimatedSprite
onready var detectPlayer = $RayCast2D
onready var interruTimer = $InterruptCD


signal enemyHealthChanged(damage)


func _ready():
	attainSprite.visible = false
	enemyHealth = 300
	doingAction = false
	isLookLeft = false
	interruTimer.wait_time = interrupCD
	animTree.active = true
	hitBox.disabled = true
	animTree.set("parameters/EnemyState/current", enemyState.IDLE)


func _process(delta):
	var playerPos : Vector2 = AutoloadScript.playerData.playerPos
	var isLeft : bool = (global_position.x - playerPos.x > 0)
	var gameObject = detectPlayer.get_collider()
	if gameObject != null && gameObject.name == "HurtBox" && !doingAction:
		doingAction = true
		animTree.set("parameters/EnemyState/current", enemyState.ATTACK)
		print("attack!!")

	if !doingAction:
		animTree.set("parameters/EnemyState/current", enemyState.IDLE)

	if (playerPos - global_position).abs() < Vector2(100, 100) && !isAttain:
		attainSprite.visible = true
		attainSprite.play("Active")
		#handle enemy turning
		if isLeft && !isLookLeft:
			animTree.set("parameters/EnemyState/current", enemyState.TURN)
			print("is on left")
			doingAction = true
			isLookLeft = true
		elif !isLeft && isLookLeft:
			animTree.set("parameters/EnemyState/current", enemyState.TURN)
			print("is on right")
			doingAction = true
			isLookLeft = false 
	elif (playerPos - global_position).abs() > Vector2(100, 100):
		attainSprite.visible = false
		isAttain = false
		attainSprite.stop()




func HandlePlayerTurn():
	if isLookLeft:
		transformer.x.x = -1
		transformer.x.y = 0
	else:
		transformer.x.x = 1
		transformer.x.y = 0

	transform.x = transformer.x * 2
	transform.y = transformer.y * 2


#TODO:apply damage to enemy
func _on_HurtBox_area_entered(area):
	if interruTimer.is_stopped():
		interruTimer.start()
		doingAction = true
		animTree.set("parameters/EnemyState/current", enemyState.GETHIT)
	var damage
	var isPlayerHit: bool = false
	var attackType: int
	if area.name == "HitBoxForAttack1":
		damage = area.playerDamage.ATTACK1
		hurtSound.play()
		print("stop it!it hurt")
		isPlayerHit = true
		attackType = 1
		cameraShake.Start(0.1, 15, 8)
		spawnEffect(blood, global_position + Vector2(-10, 10), 4)
	elif area.name == "HitBoxForAttack2":
		damage = area.playerDamage.ATTACK2
		HurtTwice()
		print("stop it!it hurt")
		isPlayerHit = true
		attackType = 2
		cameraShake.Start(0.2, 19, 10)
		spawnEffect(blood, global_position + Vector2(-10, 10), 5)
	elif area.name == "HitBoxForAttack3":
		damage = area.playerDamage.ATTACK3
		hurtSound.play()
		print("stop it!it hurt")
		isPlayerHit = true
		attackType = 3
		cameraShake.Start(0.3, 20, 15)
		spawnEffect(blood, global_position + Vector2(-10, 10), 6)

	if damage != 0 && isPlayerHit:
		spawnEffect(playerHitEffect, global_position + Vector2(-10, 10), attackType)

	enemyHealth -= damage
	emit_signal("enemyHealthChanged", damage)
	if enemyHealth <= 0:
		death()

	print("enemy current health:" + str(enemyHealth))


func HurtTwice():
	hurtSound.play()
	yield(get_tree().create_timer(0.1), "timeout")
	hurtSound.play()


func framefreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0


func spawnEffect(effect: PackedScene, effectPos: Vector2 = global_position, attackType: int = 1):
	if attackType < 4:
		var currEffect = effect.instance()
		var playerPos = get_node("../Player")
		get_tree().current_scene.add_child(currEffect)
		if playerPos.global_position.x < self.global_position.x:
			currEffect.global_scale = Vector2(-2, 2)

		else:
			currEffect.global_scale = Vector2(2, 2)

		if attackType == 1:
			currEffect.flip_v = true

		else:
			currEffect.flip_v = false

		if attackType == 2:
			currEffect.get_child(0).play("HitEffect2")

		else:
			currEffect.get_child(0).play("HitEffect")

		currEffect.global_position = effectPos
		return currEffect
	else:
		var currEffect = effect.instance()
		get_tree().current_scene.add_child(currEffect)
		currEffect.global_position = global_position + Vector2(0, 60)
		currEffect.ShowBlood(attackType)


func death():
	yield(get_tree().create_timer(0.6), "timeout")
	# animTree.set("")
	queue_free()


func _on_enemyAttaintion_animation_finished():
	isAttain = true
	attainSprite.visible = false
	attainSprite.stop()
