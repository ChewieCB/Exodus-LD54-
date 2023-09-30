extends CharacterBody2D

var enemy = null

func _on_area_2d_area_entered(area):
	$StateChart.send_event("enemy_entered")
	enemy = area.get_parent()


func _on_area_2d_area_exited(area):
	$StateChart.send_event("enemy_exited")


func _on_chase_area_entered(area):
	$StateChart.send_event("enemy_chase")


func _on_chase_area_exited(area):
	$StateChart.send_event("enemy_lost")


func _on_observing_state_processing(delta):
	look_at(enemy.global_position)


func _on_chasing_state_physics_processing(delta):
	var target_position = enemy.global_position
	look_at(target_position)
	var speed = 5
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	move_and_slide()
