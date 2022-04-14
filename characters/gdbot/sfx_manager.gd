extends Node2D

export(Array, AudioStreamSample) var sfx_leg
export(Array, AudioStreamSample) var sfx_footsteps
export(Array, AudioStreamSample) var sfx_jump
export(Array, AudioStreamSample) var sfx_squat
export(Array, AudioStreamSample) var sfx_attack_punch

onready var audio_player_leg = get_node("audio_player_leg")
onready var audio_player_footstep = get_node("audio_player_footstep")
onready var audio_player_hand = get_node("audio_player_hand")

func play_sfx_footstep():
	randomize()
	var random_index = rand_range(0,len(sfx_leg))
	audio_player_leg.stream = sfx_leg[random_index]
	audio_player_leg.play()	
	
	random_index = rand_range(0,len(sfx_footsteps))
	audio_player_footstep.stream = sfx_footsteps[random_index]
	audio_player_footstep.play()

func play_sfx_squat():
	randomize()
	var random_index = rand_range(0,len(sfx_squat))
	audio_player_leg.stream = sfx_squat[random_index]
	audio_player_leg.play()
	

func play_sfx_jump():
	randomize()
	var random_index = rand_range(0,len(sfx_jump))
	audio_player_leg.stream = sfx_jump[random_index]
	audio_player_leg.play()
	
func play_sfx_attack_punch():
	randomize()
	var random_index = rand_range(0,len(sfx_attack_punch))
	audio_player_hand.stream = sfx_attack_punch[random_index]
	audio_player_hand.play()
	
