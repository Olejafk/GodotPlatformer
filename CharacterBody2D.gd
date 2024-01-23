extends CharacterBody2D

func hurt():
	$CollisionShape2D.disabled = true 
	$MeshInstance2D.hide()
	$CPUParticles2D.emitting = true
