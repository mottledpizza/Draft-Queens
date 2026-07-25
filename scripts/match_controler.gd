extends Control

@export var team_1: Control
@export var team_2: Control

var rng = RandomNumberGenerator.new()
var strike_zone: Vector3

func _ready() -> void:
	Pitch()


func Pitch() -> void:
	var thrown_pitch = select_pitch()
	print(thrown_pitch)
	
	strike_zone = Baseball.get_strikezone(team_2.height)
	print(strike_zone)
	var target = Vector2.ZERO
	target.x = rng.randf_range(-(strike_zone.x/2) + 2,(strike_zone.x/2) + 2)
	target.y = rng.randf_range(-(strike_zone.y/2) + 2,(strike_zone.y/2) + 2)
	
	var gravity = calc_grav(thrown_pitch, team_1.pitching_speeds[thrown_pitch])
	var projected_target = target + gravity - get_pitch_spin(thrown_pitch,team_1.pitching_sauce)
	print(target)
	projected_target = throw(projected_target, thrown_pitch)
	#lets see if the ball is in the strike box
	if projected_target.x > (strike_zone.x/2) || projected_target.y > (strike_zone.y/2) || projected_target.x < -(strike_zone.x/2) || projected_target.y < -(strike_zone.y/2):
		print("Ball!")
	else:
		print("Strike!")
	#print(get_pitch_spin(thrown_pitch))


func throw(target: Vector2,thrown_pitch: String):
	var pitch_speed = snapped(rng.randfn(team_1.pitching_speeds[thrown_pitch], 2.0), 0.01)
	var inches_per_sec = pitch_speed * 17.6
	
	#calc the accuracy of the throw
	var accuracy = 1 - team_1.accuracy/100
	target.x = target.x + rng.randf_range(-(abs(target.x * accuracy) + (pitch_speed - 60)/10),abs(target.x * accuracy) + (pitch_speed - 60)/10)
	target.y = target.y + rng.randf_range(-(abs(target.y * accuracy) + (pitch_speed - 60)/10),abs(target.y * accuracy) + (pitch_speed - 60)/10)
	
	target = target + get_pitch_spin(thrown_pitch, rng.randfn(team_1.pitching_sauce)) - calc_grav(thrown_pitch,pitch_speed)
	print(target)
	return target

func calc_grav(pitch: String, speed: float):
	var x = Baseball.FROM_PITCHER_T_BATTER
	var t = x/(speed * 17.6)
	var solution =  (.5 * 9.8) * pow(t,2)
	var target = Vector2.ZERO
	target.y = target.y + solution
	return target


func get_pitch_spin(pitch: String, pitch_sauce: float):
	var pitch_type_info = Pitches.get_pitch_dic(pitch).duplicate()
	if team_1.pitch_dominant_hand == "R":
		return pitch_type_info["R_Pitch"] * (pitch_sauce/100)
	if team_1.pitch_dominant_hand == "L":
		return pitch_type_info["L_Pitch"] * (pitch_sauce/100)


#takes the perfered pitches in the player script and connectes them to the pitch arsenals to select a pitch
func select_pitch():
	var pitcher_arsenal: Array = team_1.pitching_arsenal.duplicate()
	var pitch_weights: PackedFloat32Array
	
	#set the weights for all of the perfered pitches
	for i in pitcher_arsenal.size():
		pitch_weights.append(team_1.perfered_pitches[pitcher_arsenal[i]])
	
	return pitcher_arsenal[rng.rand_weighted(pitch_weights)]
