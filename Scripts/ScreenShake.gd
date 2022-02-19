extends Node

onready var shakeTween = $ShakeTween
onready var camera = get_parent()
onready var timer = $Timer
onready var durationTimer = $Duration

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
# var priority = 0


func Start(duration = 0.2, frequency = 15, amplitude = 16):
	self.amplitude = amplitude

	durationTimer.wait_time = duration
	timer.wait_time = 1 / float(frequency)

	durationTimer.start()
	timer.start()

	ScreenShake()


func ScreenShake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	shakeTween.interpolate_property(
		camera, "offset", camera.offset, rand, timer.wait_time, TRANS, EASE
	)
	shakeTween.start()


func ResetCam():
	shakeTween.interpolate_property(
		camera, "offset", camera.offset, Vector2(), timer.wait_time, TRANS, EASE
	)
	shakeTween.start()


func _on_Timer_timeout():
	ScreenShake()


func _on_Duration_timeout():
	ResetCam()
	timer.stop()
