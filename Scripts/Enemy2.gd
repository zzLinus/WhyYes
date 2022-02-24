extends KinematicBody2D

var enemyHealth: int
var playerPos: Vector2
var isAttain: bool = false
var setLookLeft: bool = true
var isLookLeft: bool = false
var enemyVelocity: Vector2 = Vector2(0, 0)
var transformer = Transform2D()
var interrupCD: float = 4
var attenDisten: int = 200
var bulletNum: int = 6
var diraction

export(bool) var doingAction
export(PackedScene) var playerHitEffect: PackedScene
export(PackedScene) var blood: PackedScene

enum enemyState { IDLE, GETHIT, ATTACK, RUN, PREPARE, RELOAD, PUTAWAY }

onready var animTree = $AnimationTree
onready var bladeSound = $BladeSound
onready var cameraShake = get_node("../Player/Camera2D/Node")
onready var hurtSound = $Hurt
onready var attainSprite = $enemyAttaintion
onready var detectPlayer = $RayCast2D
onready var interruTimer = $InterruptCD
onready var firePoint = $FirePoint
onready var firePoint2 = $FirePoint2

signal enemyHealthChanged(damage)
signal enemyDeath

const bullet = preload("res://Scenes/Bullet.tscn")


func _ready():
	attainSprite.visible = false
	enemyHealth = 300
	doingAction = false
	isLookLeft = false
	interruTimer.wait_time = interrupCD
	animTree.active = true
	animTree.set("parameters/EnemyState/current", enemyState.IDLE)


func _process(delta):
	var playerPos: Vector2 = AutoloadScript.playerData.playerPos
	var isLeft: bool = global_position.x - playerPos.x > 0
	var gameObject = detectPlayer.get_collider()
	diraction = HandleMovement(playerPos)
	diraction = diraction.normalized()


	#handle turning
	if !doingAction:
		if (playerPos - global_position).length() < attenDisten && !isAttain:
			isAttain = true
			attainSprite.visible = true
			attainSprite.play("Active")
			#handle enemy turning
			if isLeft && !isLookLeft:
				isLookLeft = true
				HandlePlayerTurn()
			elif !isLeft && isLookLeft:
				isLookLeft = false
				HandlePlayerTurn()
		elif (playerPos - global_position).length() > attenDisten:
			attainSprite.visible = false
			isAttain = false
			attainSprite.stop()
		elif isAttain:
			if isLeft && !isLookLeft:
				isLookLeft = true
				HandlePlayerTurn()
			elif !isLeft && isLookLeft:
				isLookLeft = false
				HandlePlayerTurn()


	if !doingAction:
		if !isAttain:
			animTree.set("parameters/EnemyState/current", enemyState.IDLE)
		else:
			if isLookLeft:
				var moveto = playerPos + Vector2(100, 0)
			else:
				var moveto = playerPos + Vector2(-100, 0)
			# if (global_position - playerPos).length() < 100:
			move_and_slide(-diraction * 100)
			animTree.set("parameters/EnemyState/current", enemyState.RUN)


	#handle attack
	if isAttain && !doingAction:
		doingAction = true
		if bulletNum >= 2:
			animTree.set("parameters/EnemyState/current", enemyState.PREPARE)
			yield(get_tree().create_timer(0.45), "timeout")
			animTree.set("parameters/EnemyState/current", enemyState.ATTACK)
			yield(get_tree().create_timer(1.05), "timeout")
			animTree.set("parameters/EnemyState/current", enemyState.PUTAWAY)
		else:
			animTree.set("parameters/EnemyState/current", enemyState.RELOAD)
			bulletNum = 6
			yield(get_tree().create_timer(0.8), "timeout")
			animTree.set("parameters/EnemyState/current", enemyState.ATTACK)




func HandleMovement(playerpos) -> Vector2:
	var diraction: Vector2
	diraction = playerpos - $FirePoint.global_position
	animTree.set("parameter/EnemyState/current", enemyState.RUN)
	return diraction


func Shoot():
	bulletNum -= 2
	var projectile = bullet.instance()
	var projectile2 = bullet.instance()

	projectile.linear_velocity = Vector2(500 * diraction)
	projectile2.linear_velocity = Vector2(500 * diraction)
	if !isLookLeft:
		projectile.rotate(diraction.angle())
		projectile2.rotate(diraction.angle())
	else:
		projectile.rotate(PI - diraction.angle())
		projectile2.rotate(PI - diraction.angle())

	call_deferred("add_child", projectile)
	projectile.global_position = firePoint.position
	call_deferred("add_child", projectile2)
	projectile.global_position = firePoint.position


func HandlePlayerTurn():
	if isLookLeft:
		transformer.x.x = -1
		transformer.x.y = 0
	else:
		transformer.x.x = 1
		transformer.x.y = 0

	transform.x = transformer.x * 2
	doingAction = false
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
	animTree.set("parameters/EnemyState/current", enemyState.GETHIT)


func CheckDead():
	if enemyHealth <= 0:
		queue_free()


func _on_enemyAttaintion_animation_finished():
	attainSprite.visible = false
	attainSprite.stop()
