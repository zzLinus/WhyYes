extends AnimatedSprite

export(int) var trapType

onready var animPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	if trapType == 1:
		animPlayer.play("trap1")
	if trapType == 2:
		animPlayer.play("trap2")
	if trapType == 3:
		animPlayer.play("trap3")
	if trapType == 4:
		animPlayer.play("trap4")
	if trapType == 5:
		animPlayer.play("trap5")
	if trapType == 6:
		animPlayer.play("trap6")
