extends RigidBody2D

# External nodes
onready var light = get_node("light")
onready var audio_player = get_node("audio_player")

# Properties
export(Array,AudioStream) var sfxs
var attack_damage_value = 10

# Data handlers
var sfx_index = 0
enum Mode {Safe, Lethal}
var current_mode = Mode.Safe


func _ready():
	connect("body_entered",self,"_on_body_entered")
	
func _process(delta):
	light.energy += delta
	if light.energy > 0.88:
		light.energy = 0.88

func _on_body_entered(body):
	play_sfx()
	apply_damage(body)

func play_sfx():
	randomize()
	
	audio_player.stream = sfxs[sfx_index]
	audio_player.play()
	
	sfx_index +=1
	if sfx_index > len(sfxs)-1:
		sfx_index = 0

func apply_damage(body):
	if current_mode == Mode.Lethal:
		if body!=self:
			if body.has_method("receive_damage"):
				body.receive_damage(attack_damage_value)

func receive_damage(damage_value:int):
	light.energy = 0
	if current_mode == Mode.Safe:
		current_mode = Mode.Lethal
		light.color = Color.red
		print("Lethal")
		
	elif current_mode == Mode.Lethal:
		current_mode = Mode.Safe
		light.color = Color.yellow
		print("Safe")
