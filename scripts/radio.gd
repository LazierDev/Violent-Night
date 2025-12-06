extends StaticBody3D

@onready var song_1: AudioStreamPlayer3D = $"../song_1"
@onready var song_2: AudioStreamPlayer3D = $"../song_2"
@onready var song_3: AudioStreamPlayer3D = $"../song_3"
@onready var song_4: AudioStreamPlayer3D = $"../song_4"
@onready var song_5: AudioStreamPlayer3D = $"../song_5"
@onready var song_6: AudioStreamPlayer3D = $"../song_6"
@onready var song_7: AudioStreamPlayer3D = $"../song_7"
@onready var song_8: AudioStreamPlayer3D = $"../song_8"

@onready var label: Label = $"../ui/Label"

var cur_song : AudioStreamPlayer3D
var near := false
var time_stamp := 0.0
var songs := []

func _ready() -> void:
	for child in $"..".get_children():
		if child is AudioStreamPlayer3D:
			songs.append(child)
	
	cur_song = songs.pick_random()
	#cur_song.play()


func _process(_delta: float) -> void:
	label.text = cur_song.name
	if Input.is_action_just_pressed("e") and near:
		$"../clck".play()
		$"../GPUParticles3D".emitting = true
		song_switch()
	if Input.is_action_just_pressed("q") and near:
		$"../clck".play()
		if cur_song.playing:
			time_stamp = cur_song.get_playback_position()
			cur_song.stop()
			$"../GPUParticles3D".emitting = false
		else:
			cur_song.play(time_stamp)
			$"../GPUParticles3D".emitting = true


func _on_song_1_finished() -> void:
	cur_song = song_2
	song_2.play()


func _on_song_2_finished() -> void:
	cur_song = song_3
	song_3.play()


func _on_song_3_finished() -> void:
	cur_song = song_4
	song_4.play()


func _on_song_4_finished() -> void:
	cur_song = song_5
	song_5.play()


func _on_song_5_finished() -> void:
	cur_song = song_6
	song_6.play()


func _on_song_6_finished() -> void:
	cur_song = song_7
	song_7.play()


func _on_song_7_finished() -> void:
	cur_song = song_8
	song_8.play()


func _on_song_8_finished() -> void:
	cur_song = song_1
	song_1.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		near = true
		$"../Label3D".visible = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		near = false
		$"../Label3D".visible = false

func song_switch():
		match cur_song:
			song_1 : 
					_on_song_1_finished()
					song_1.stop()
			song_2 : 
					_on_song_2_finished()
					song_2.stop()
			song_3 : 
					_on_song_3_finished()
					song_3.stop()
			song_3 : 
					_on_song_3_finished()
					song_3.stop()
			song_4 : 
					_on_song_4_finished()
					song_4.stop()
			song_5 : 
					_on_song_5_finished()
					song_5.stop()
			song_6 : 
					_on_song_6_finished()
					song_6.stop()
			song_7 : 
					_on_song_7_finished()
					song_7.stop()
			song_8 : 
					_on_song_8_finished()
					song_8.stop()
