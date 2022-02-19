extends TextureProgress

onready var tween = $Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_parent())
	if get_parent().name != "Enemy":
		rect_scale = Vector2(4, 4)
	if get_parent().name == "Enemy":
		max_value = AutoloadScript.enemyData.enemyMaxHealth
		value = max_value
		print("enemyMaxHealth" + str(max_value))
	if get_parent().name == "PlayerUI":
		max_value = AutoloadScript.playerData.playerMaxHealth
		value = AutoloadScript.playerData.playerHealth
		print("playerMaxHealth" + str(max_value))


func animHealthBar(start, end):
	tween.interpolate_property(self, "value", start, end, 1.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func _on_Player_healthChanged(damage: int):
	var start = value
	animHealthBar(start, start - damage)


func _on_KinematicBody2D_enemyHealthChanged(damage: int):
	var start = value
	animHealthBar(start, start - damage)