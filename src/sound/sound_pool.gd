@tool
extends Node

var _sounds: Array[AudioStreamPlayer] = []
var _random: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_index: int = -1


func _ready():
	for child in get_children():
		if child is AudioStreamPlayer:
			_sounds.append(child)


func _get_configuration_warnings():
	var number_of_audio_player_children: int = 0
	for child in get_children():
		if child is AudioStreamPlayer:
			number_of_audio_player_children += 1
	if number_of_audio_player_children < 2:
		return ["Expected two or more children of type AudioStreamPlayer."]
	return []


func play_random_sound():
	var index: int = _random.randi_range(0, _sounds.size() - 1)
	while index == _last_index:
		index = _random.randi_range(0, _sounds.size() - 1)
	_last_index = index
	_sounds[index].play() 

