extends StaticBody2D

func _physics_process(delta):
	pass

func destroy():
	$CollisionShape2D.disabled = true 
	$MeshInstance2D.hide()
	$CPUParticles2D.emitting = true
