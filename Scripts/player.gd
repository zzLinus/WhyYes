extends KinematicBody2D
export(bool) var doingAction
export(bool) var doingTrans
export(bool) var doingDash

export(PackedScene) var runSmokeEffect: PackedScene
export(PackedScene) var enemyHitEffect: PackedScene
export(PackedScene) var blood: PackedScene
export(PackedScene) var darkMagicEffect: PackedScene

var playerSpeed: int = 250
var playerVelocity: Vector2 = Vector2.ZERO
var transformer = Transform2D()
var playerState
var isRunning: bool
var comboAction: int
var playerHealth: int
var comboTrigger: bool
var spawnPointID: int
var interrupCD: float = 3
var points = []
var dashDelay = 0.3

onready var playerSprite = $AnimatedSprite
onready var animTree = $AnimationTree
onready var animPlayer = $AnimationPlayer
onready var comboTimer = $Timer
onready var bladeSound = $BladeSound
onready var cameraShake = $Camera2D/Node
onready var hurtSound = $Hurt
onready var dashSound = $Dash
onready var interrupTimer = $InterruTimer
onready var playerShadow = $PlayerShadow
onready var transportMain = get_node("../TransportMain")
onready var dashDuration = $DashDuration

enum SWstate { WITHSWORD, WOSWORD }
enum NMstate { IDLE, RUN, DEATH, GETHIT, PUTSWORD, DASH, ROLL }
enum WSstate {
	PARRY,
	IDLE,
	PARRYWITHOUTHIT,
	RUN,
	STOPATTACK,
	GETHIT,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	TAKESWORD,
	ROLL
}

signal healthChanged(damage)
signal playerDead

const transportPoint = preload("res://Scenes/TransportPoint.tscn")


func _ready():
	animTree.active = true
	comboTrigger = false
	global_scale *= 0.7
	doingTrans = false
	doingAction = false
	doingDash = false
	comboAction = WSstate.ATTACK1
	interrupTimer.wait_time = interrupCD

	if AutoloadScript.playerData.playerIsFirstLoad:
		animPlayer.play_backwards("SceneTransition")
		print("load first time")
		AutoloadScript.currentScene = 1
		playerHealth = 100
		playerState = SWstate.WOSWORD
		global_position = Vector2(1080, 1626)
		emit_signal("healthChanged", 0)
		AutoloadScript.playerData.playerIsFirstLoad = false
	else:
		print("load not first time")
		AutoloadScript.currentScene += 1
		LoadPlayerData()
		global_position = AutoloadScript.GetSpawnPoint()

	#init animtaiontree && set init value
	animTree.set("parameters/PlayerState/current", playerState)
	animTree.set("parameters/NMTransition/current", NMstate.IDLE)
	animTree.set("parameters/WSTransition/current", WSstate.IDLE)


func _process(delta):
	AutoloadScript.playerData.playerPos = $HurtBox.global_position
	#switch animation group
	if !doingAction && !doingDash:
		handlePlayerState()

	#switch animation in norm state animgroup or ws animgroup
	if !doingTrans:
		handlePlayerAnim()

	#handle dash movement
	if doingDash && global_scale.y < 0:
		move_and_slide(Vector2(-350, 0))
	elif doingDash && global_scale.y > 0:
		move_and_slide(Vector2(350, 0))

	if !doingTrans && !doingAction && !doingDash:
		isRunning = handleMovement(delta)

	if dashDuration.is_stopped() && points.size():
		ClearTransportPoints(0)


func handlePlayerAnim():
	if playerState == 1:
		handleNormAnim()
	else:
		handleWithSwordAnim()


func handleWithSwordAnim():
	if (
		Input.is_action_just_pressed("attack")
		&& (!comboTimer.is_stopped() || !doingAction)
		&& !doingDash
	):
		handleAttackAnim()
		return
	elif Input.is_action_just_pressed("Roll") && !doingAction:
		animTree.set("parameters/WSTransition/current", WSstate.ROLL)
		return
	elif Input.is_action_just_pressed("Parry") && !doingAction:
		animTree.set("parameters/WSTransition/current", WSstate.PARRYWITHOUTHIT)
		return
	elif !doingAction && !doingDash:
		if isRunning == true:
			animTree.set("parameters/WSTransition/current", WSstate.RUN)
		else:
			animTree.set("parameters/WSTransition/current", WSstate.IDLE)


func handleNormAnim():
	if Input.is_action_just_pressed("Dash") && !doingDash && dashDuration.is_stopped() && !doingAction:
		playerDash()
	# elif Input.is_action_just_released("Dash"):
	# 	dashDuration.stop()
	# 	ClearTransportPoints(0)
	elif Input.is_action_just_pressed("Roll") && !doingAction:
		animTree.set("parameters/NMTransition/current", NMstate.ROLL)
		return
	elif !doingAction && !doingDash:
		if isRunning == true:
			animTree.set("parameters/NMTransition/current", NMstate.RUN)
		else:
			animTree.set("parameters/NMTransition/current", NMstate.IDLE)

	if !dashDuration.is_stopped() && Input.is_action_just_released("Dash"):
		var playerVol: Vector2
		playerVol.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
		playerVol.y = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
		#UP
		if playerVol == Vector2(0, -1):
			points[6].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[6].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#DOWN
		if playerVol == Vector2(0, 1):
			points[2].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[2].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#LEFT
		if playerVol == Vector2(-1, 0):
			points[4].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[4].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#RIGHT
		if playerVol == Vector2(1, 0):
			points[0].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[0].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#UP LEFT
		if playerVol == Vector2(-1, -1):
			points[5].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[5].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#UP RIGHT
		if playerVol == Vector2(1, -1):
			points[7].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[7].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#DOWN LEFT
		if playerVol == Vector2(-1, 1):
			points[3].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[3].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return
		#DOWN RIGHT
		if playerVol == Vector2(1, 1):
			points[1].PlayFlash()
			animTree.set("parameters/NMTransition/current", NMstate.DASH)
			yield(get_tree().create_timer(dashDelay), "timeout")
			dashDuration.stop()
			global_position = points[1].global_position + Vector2(0, -30)
			ClearTransportPoints(1)
			return

		ClearTransportPoints(0)


func handleAttackAnim():
	if !doingAction:
		animTree.set("parameters/WSTransition/current", comboAction)
		comboAction += 1

		if comboAction == WSstate.ATTACK2:
			yield(get_tree().create_timer(0.1), "timeout")
			comboTimer.start()
			return
	else:
		if !comboTrigger:
			comboTrigger = true


func playerDash():
	var diractions = [
		Vector2(1, 0).normalized(),
		Vector2(1, 1).normalized(),
		Vector2(0, 1).normalized(),
		Vector2(-1, 1).normalized(),
		Vector2(-1, 0).normalized(),
		Vector2(-1, -1).normalized(),
		Vector2(0, -1).normalized(),
		Vector2(1, -1).normalized()
	]
	dashDuration.start()
	for i in range(8):
		yield(get_tree().create_timer(0.04), "timeout")
		points.append(
			spawnEffect(transportPoint, Vector2(0, 20) + global_position + diractions[i] * 130)
		)


func ClearTransportPoints(type: int):
	if type == 0:
		for i in range(8):
			yield(get_tree().create_timer(0.1), "timeout")
			points[i].queue_free()
	elif type == 1:
		for i in range(8):
			points[i].queue_free()

	points.clear()


func handleMovement(delta):
	playerVelocity.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	playerVelocity.y = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	playerVelocity = playerVelocity.normalized()

	#weird scale issues see godot github issue #17405
	if playerVelocity.x < 0 and global_scale.x > 0:
		transformer.x.x = -1
		transformer.x.y = 0
	elif playerVelocity.x > 0:
		transformer.x.x = 1
		transformer.x.y = 0

	transform.x = transformer.x
	transform.y = transformer.y

	move_and_slide(playerVelocity * playerSpeed)
	if playerVelocity.length() > 0:
		return true
	else:
		return false


func handlePlayerState():
	if Input.is_action_just_pressed("SwitchWeapon") && playerState == SWstate.WOSWORD:
		playerState = SWstate.WITHSWORD
		animTree.set("parameters/PlayerState/current", SWstate.WITHSWORD)
		animTree.set("parameters/WSTransition/current", WSstate.TAKESWORD)
		doingTrans = true
	elif Input.is_action_just_pressed("SwitchWeapon") && playerState == SWstate.WITHSWORD:
		playerState = SWstate.WOSWORD
		animTree.set("parameters/PlayerState/current", SWstate.WOSWORD)
		animTree.set("parameters/NMTransition/current", NMstate.PUTSWORD)
		doingTrans = true


#AnimationTree Node BUG see issue #28311(can't trigger any signal when using animationtree node to control animation
# sprite or animationPlayer)
#
# func _on_AnimationPlayer_animation_finished(anim_name):
# 	print("wublabdubdub")
# 	pass # Replace with function body.
#
#
# func _on_AnimationPlayer_animation_started(anim_name):
# 	mrint("wublabdubdub")
# 	pass # Replace with function body.
#
#
# func _on_AnimatedSprite_animation_finished():
# 	mrint("wublabdubdub")
# 	pass # Replace with function body.


#TODO: add screen shake when enemy get hit or maybe frame freeze
func putAwaySwordCallBack():
	doingTrans = false


func takeSwordCallBack():
	doingTrans = false


func attack1CallBack():
	pass


func attack2CallBack():
	pass


func attack3CallBack():
	pass


func _on_Timer_timeout():
	pass


func handleStopAttack():
	if comboAction == WSstate.ATTACK2:
		triggerStopAttackShot()
	elif comboAction == WSstate.ATTACK3:
		triggerStopAttackShot2()
	elif comboAction == WSstate.ATTACK1:
		triggerStopAttackShot3()


func triggerStopAttackShot():
	if !comboTrigger:
		comboAction = WSstate.ATTACK1
		animTree.set("parameters/StopAttack/active", true)
	else:
		print("combo action2 activate")
		comboTrigger = false
		animTree.set("parameters/WSTransition/current", comboAction)
		comboAction += 1
		yield(get_tree().create_timer(0.2), "timeout")
		comboTimer.start()
		return


func triggerStopAttackShot2():
	if !comboTrigger:
		animTree.set("parameters/StopAttack2/active", true)
		comboAction = WSstate.ATTACK1
	else:
		comboTrigger = false
		print("combo action3 activate")
		animTree.set("parameters/WSTransition/current", comboAction)
		comboAction = WSstate.ATTACK1


func triggerStopAttackShot3():
	comboTrigger = false
	print("combo3 take back action activating")
	animTree.set("parameters/StopAttack3/active", true)


func _on_HurtBox_area_entered(area: Area2D):
	#handle animation
	if animTree.get("parameters/WSTransition/current") == WSstate.PARRYWITHOUTHIT:
		animTree.set("parameters/WSTransition/current", WSstate.PARRY)
		return
	elif animTree.get("parameters/WSTransition/current") == WSstate.PARRY:
		return

	if interrupTimer.is_stopped():
		interrupTimer.start()
		doingAction = true
		comboAction = WSstate.ATTACK1
		if playerState == SWstate.WOSWORD:
			animTree.set("parameters/PlayerState/current", SWstate.WOSWORD)
			animTree.set("parameters/NMTransition/current", NMstate.GETHIT)
		else:
			animTree.set("parameters/PlayerState/current", SWstate.WITHSWORD)
			animTree.set("parameters/WSTransition/current", WSstate.GETHIT)

	var damage
	if area.name == "EnemyAttack":
		damage = area.enemyDamage.ATTACK
		hurtSound.play()
		cameraShake.Start()
	if area.name == "Bullet":
		damage = area.enemyDamage.ATTACK
		hurtSound.play()
		cameraShake.Start()
	elif area.name == "PhyTrapHitBox":
		damage = area.trapDamage[area.get_parent().trapType]
		print("hurt by physical tray")
		cameraShake.Start()
	elif area.name == "Magic":
		damage = 10
		hurtSound.play()
		cameraShake.Start()

	if damage != 0:
		playerHealth -= damage
		spawnEffect(enemyHitEffect, global_position + Vector2(-10, 10))
		emit_signal("healthChanged", damage)

	if playerHealth <= 0:
		death()

	print("player current health:" + str(playerHealth))


func spawnRunSmoke():
	spawnEffect(runSmokeEffect, global_position + Vector2(0, 30))


func spawnEffect(effect: PackedScene, effectPos: Vector2 = global_position):
	var currEffect = effect.instance()
	if currEffect.name == "transport":
		var playerNode = get_tree().get_nodes_in_group("Player")
		transportMain.add_child(currEffect)
		print("add child to player")
	else:
		get_tree().current_scene.add_child(currEffect)
	if currEffect.name == "EnemyHitEffect":
		currEffect.get_child(0).play("HitEffect")
	if currEffect.name == "DarkMagicEffect":
		currEffect.get_child(0).play("DarkMagic")
	currEffect.global_position = effectPos
	return currEffect
	# AutoloadScript.playerData.playerSpawnPoint


func death():
	var musicPlayers = get_tree().get_nodes_in_group("BGM")
	for player in musicPlayers:
		player.stop()
	animTree.set("parameters/PlayerState/current", SWstate.WOSWORD)
	animTree.set("parameters/NMTransition/current", NMstate.DEATH)
	emit_signal("playerDead")


func SavePlayerData():
	animPlayer.play("SceneTransition")
	AutoloadScript.playerData.playerHealth = playerHealth
	AutoloadScript.playerData.playerSpeed = playerSpeed
	AutoloadScript.playerData.playerState = playerState
	AutoloadScript.playerData.playerComboAction = comboAction
	AutoloadScript.playerData.playerSpawnPoint = spawnPointID
	print("player data saved")
	print(AutoloadScript.playerData)


func LoadPlayerData():
	animPlayer.play_backwards("SceneTransition")
	playerHealth = AutoloadScript.playerData.playerHealth
	playerState = AutoloadScript.playerData.playerState
	spawnPointID = AutoloadScript.playerData.playerSpawnPoint
	playerShadow.visible = true
	emit_signal("healthChanged", 0)
	print(AutoloadScript.playerData)
	print("player data loaded")


func _on_InteractWithPortal_area_entered(area):
	if (
		area.name == "Portal"
		|| area.name == "Portal1-1"
		|| area.name == "Portal1-2"
		|| area.name == "Portal1-3"
	):
		if playerState == SWstate.WITHSWORD:
			animTree.set("parameters/WSTransition/current", WSstate.IDLE)
		if playerState == SWstate.WOSWORD:
			animTree.set("parameters/NMTransition/current", NMstate.IDLE)
		if area.name == "Portal":
			spawnPointID = 1
		if area.name == "Portal1-1":
			spawnPointID = 2
		if area.name == "Portal1-2":
			spawnPointID = 3
		if area.name == "Portal1-3":
			spawnPointID = 4
		SavePlayerData()
		spawnEffect(darkMagicEffect, global_position)
		doingAction = true
		playerSprite.visible = false
		playerShadow.visible = false
	elif area.name == "PhyTrapHitBox":
		var damage = area.trapDamage[area.get_parent().trapType]
		print("hurt by physical tray")
		cameraShake.Start()
		playerHealth -= damage
		emit_signal("healthChanged", damage)
		if playerHealth <= 0:
			death()


func _on_Ztransform_body_exited(body: Node):
	self.z_index = 3
	print("body exit")


func _on_Ztransform_body_entered(body: Node):
	self.z_index = 1
	print("body enter")


func _on_Ztransform_area_entered(area):
	self.z_index = 1
	print("body enter")


func _on_Ztransform_area_exited(area):
	self.z_index = 3
