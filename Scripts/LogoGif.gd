extends AnimatedSprite

enum Dirac { RIGHT, LEFT, DOWN, UP }


func _ready():
	visible = false


func _on_DiractionSign_diraction(dirac):
	print("give sign")
	visible = true
	if dirac == Dirac.RIGHT:
		print("=>>>>>" + str(dirac))
		play("ActiveRight")
	elif dirac == Dirac.LEFT:
		play("ActiveLeft")
	elif dirac == Dirac.UP:
		play("ActiveUp")
	elif dirac == Dirac.DOWN:
		play("ActiveDown")



func _on_DiractionSign_deactive():
	visible = false
