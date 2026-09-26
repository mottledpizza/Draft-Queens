extends Control

@export var team_1: Control
@export var team_2: Control

var rng = RandomNumberGenerator.new()
var strike_zone: Vector3
var ball_target: Vector2
var pitch_speed: float
var thrown_pitch: String

func _ready() -> void:
	Pitch()
	Bat()


func Bat() -> void:
	#i/s -> i/ms
	var time_to_react = 766 / ((pitch_speed * 17.6)/1000)
	time_to_react = time_to_react - ((team_2.swing_length * 12) / ((team_2.bat_speed * 17.6)/1000)) - 125
	var can_react = false
	if time_to_react > team_2.reaction_speed:
		can_react = true
	var guessed_pitch = predictPitch(can_react)
	print(guessed_pitch)
	swingBat(guessed_pitch)
	

#IMPORTANT: DAVID! put the formula in this func pretty please
func calcBatPhysics(ball_velocity: float, bat_velocity: float, bat_length: float):
	pass

func swingBat(guessed_pitch: String):
	var target = Vector2.ZERO
	target = ball_target + get_pitch_spin(guessed_pitch, team_1.pitching_sauce) - calc_grav(guessed_pitch,pitch_speed)
	print("I'm Gonna Hit Here! ", target)
	
	


func predictPitch(can_react: bool ):
	var predictedPitch: String
	if !can_react: 
		predictedPitch = select_pitch()
	else:
		predictedPitch = select_pitch(thrown_pitch, team_2.batting_compitence)
	return predictedPitch
	


func Pitch() -> void:
	thrown_pitch = select_pitch()
	print(thrown_pitch)
	
	strike_zone = Baseball.get_strikezone(team_2.height)
	print(strike_zone)
	var target = Vector2.ZERO
	target.x = rng.randf_range(-(strike_zone.x/2) + 2,(strike_zone.x/2) + 2)
	target.y = rng.randf_range(-(strike_zone.y/2) + 2,(strike_zone.y/2) + 2)
	
	var gravity = calc_grav(thrown_pitch, team_1.pitching_speeds[thrown_pitch])
	var projected_target = target + gravity - get_pitch_spin(thrown_pitch,team_1.pitching_sauce)
	ball_target = projected_target
	projected_target = throw(projected_target, thrown_pitch)
	print("The Ball is Going Here! ",projected_target)
	#lets see if the ball is in the strike box
	if projected_target.x > (strike_zone.x/2) || projected_target.y > (strike_zone.y/2) || projected_target.x < -(strike_zone.x/2) || projected_target.y < -(strike_zone.y/2):
		print("Ball!")
	else:
		print("Strike!")


func throw(target: Vector2,thrown_pitch: String):
	pitch_speed = snapped(rng.randfn(team_1.pitching_speeds[thrown_pitch], 2.0), 0.01)
	var inches_per_sec = pitch_speed * 17.6
	
	#calc the accuracy of the throw
	var accuracy = 1 - team_1.accuracy/100
	target.x = target.x + rng.randf_range(-(abs(target.x * accuracy) + (pitch_speed - 60)/10),abs(target.x * accuracy) + (pitch_speed - 60)/10)
	target.y = target.y + rng.randf_range(-(abs(target.y * accuracy) + (pitch_speed - 60)/10),abs(target.y * accuracy) + (pitch_speed - 60)/10)
	
	target = target + get_pitch_spin(thrown_pitch, rng.randfn(team_1.pitching_sauce)) - calc_grav(thrown_pitch,pitch_speed)
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


#takes the perfered pitches in the player script and connects them to the pitch arsenals to select a pitch
func select_pitch(thrownpitch: String = "null", competence: float = 0.0 ):
	var pitcher_arsenal: Array = team_1.pitching_arsenal.duplicate()
	var pitch_weights: PackedFloat32Array
	
	#set the weights for all of the perfered pitches
	for i in pitcher_arsenal.size():
		if thrownpitch == pitcher_arsenal[i]:
			pitch_weights.append(team_1.perfered_pitches[pitcher_arsenal[i]] * (((competence/2)/100) + 1 ))
		else:
			pitch_weights.append(team_1.perfered_pitches[pitcher_arsenal[i]])
	
	return pitcher_arsenal[rng.rand_weighted(pitch_weights)]

func getWhereBallThrownFrom():
	var gravity = calc_grav(thrown_pitch, team_1.pitching_speeds[thrown_pitch])
	var spot_thrown_from = ball_target - gravity + get_pitch_spin(thrown_pitch,team_1.pitching_sauce)
	return spot_thrown_from
	
