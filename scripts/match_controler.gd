extends Control

@export var team_1: Control
@export var team_2: Control

var rng = RandomNumberGenerator.new()
var strike_zone: Vector3
var ball_target: Vector2
var pitch_speed: float
var thrown_pitch: String

func _ready() -> void:
	var target = Pitch()
	Bat(target)


func Bat(target: Vector2) -> void:
	#i/s -> i/ms
	#planning to expand this later
	var bat_speed = team_2.bat_speed
	var time_to_react = 766 / ((pitch_speed * 17.6)/1000)
	time_to_react = time_to_react - ((team_2.swing_length * 12) / (( bat_speed * 17.6)/1000)) - 125
	var can_react = false
	if time_to_react > team_2.reaction_speed:
		can_react = true
	var guessed_pitch = predictPitch(can_react)
	print(guessed_pitch)
	swingBat(guessed_pitch, 766 / ((pitch_speed * 17.6)/1000), target, pitch_speed, bat_speed)
	
	

#IMPORTANT: DAVID! put the formula in this func pretty please
func calcBatPhysics(bat_x_angle: float, bat_y_angle: float, ball_height: float, bat_height: float, ball_diameter: float, bat_diameter: float, 
ball_mass: float, bat_mass:float, ball_velocity: float, bat_velocity: float, bat_length: float):
	#bunch o nonsense, kill it all when you put in the equasion (womp womp too many typos)
	print("Bat X Angle is: ", bat_x_angle)
	print("Bat Y Angle is: ", bat_y_angle)
	print("Ball Height is: ", ball_height)
	print("Bat Height is: ", bat_height)
	print("Ball Diameter is: ", ball_diameter)
	print("Bat Diameter is: ", bat_diameter)
	print("Ball Mass is: ", ball_mass)
	print("Bat Mass is: ", bat_mass)
	print("Ball Velocity is: ",ball_velocity)
	print("Bat Velocity is: ", bat_velocity)
	print("Bat Length is: ", bat_length)
	
	pass

func swingBat(guessed_pitch: String, ball_time: float,ball_strike_point, pitch_speed: float, bat_speed: float):
	var target = Vector2.ZERO
	target = ball_target + get_pitch_spin(guessed_pitch, team_1.pitching_sauce) - calc_grav(guessed_pitch,pitch_speed)
	print("I'm Gonna Hit Here! ", target)
	var predicted_time_to_hit = snapped(rng.randfn(team_1.pitching_speeds[guessed_pitch], 2.0), 0.01)
	predicted_time_to_hit = 766 / ((predicted_time_to_hit * 17.6)/1000)
	print("time to hit: ",predicted_time_to_hit)
	print("ball time: ", ball_time)
	
	var batPoints: Array
	var angles: PackedFloat32Array
	if (predicted_time_to_hit - ball_time) < 0:
		#fyi it technically should be based off of the speed of the swing and the ball but uhhh i don't really care :P
		var distance_offset = (ball_time - predicted_time_to_hit)/2
		angles = batRot(predicted_time_to_hit,distance_offset)
		batPoints = createBatPoints(target)
		batPoints = rotateBatFuction(batPoints,angles[1], ball_strike_point)
		print("Swing is faster")
	elif (predicted_time_to_hit - ball_time) > 0:
		var distance_offset = (predicted_time_to_hit - ball_time)/2
		angles = batRot(predicted_time_to_hit,-distance_offset)
		batPoints = createBatPoints(target)
		batPoints = rotateBatFuction(batPoints,angles[1], ball_strike_point)
		print("Ball is faster!")
	elif (predicted_time_to_hit - ball_time) == 0:
		#statistically impossible... but just in case 
		print("Perfect!")
	doesBallHitBat(batPoints, target)
	calcBatPhysics(angles[0],angles[1],ball_strike_point.y,target.y,Baseball.BALL_DIAMETER,team_2.getBat().bat_diameter,
	Baseball.BALL_WEIGHT,team_2.getBat().bat_weight, pitch_speed, bat_speed, team_2.getBat().bat_length)

#gets the bat X angle
func batRot(time_to_hit: float, offset: float):
	var bat_speed = team_2.swing_length / time_to_hit
	var new_distance = (bat_speed * offset) * 12
	var diamiter = team_2.getBat().bat_length * 2
	var rads_x = new_distance / (diamiter/2)
	#only turns rads into degrees, can be removed if we're working in rads
	var degree_x = rads_x * (180/PI)
	var degree_y = -(team_2.tilt + rng.randf_range(-1,1)) - abs(degree_x)
	
	var anglesOut: PackedFloat32Array
	anglesOut.append(degree_x)
	anglesOut.append(degree_y)
	print("Y degree ", degree_y)
	print("X degree ", degree_x)
	return anglesOut

func predictPitch(can_react: bool ):
	var predictedPitch: String
	if !can_react: 
		predictedPitch = select_pitch()
	else:
		predictedPitch = select_pitch(thrown_pitch, team_2.batting_compitence)
	return predictedPitch

func Pitch():
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
	return projected_target


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
	
func createBatPoints(target: Vector2):
	var bat: base_bat
	bat = team_2.getBat()
	var height = bat.bat_diameter / 2
	var length = bat.bat_length
	var origin = target
	var vec2: Vector2
	#array is formated that 0 is the top of the tip, 1 is the bottom of the tip
	#2 is top of handle 3 is bottom of handle
	var batPoints = []
	vec2 = origin
	vec2.x += bat.sweet_spot
	vec2.y += height
	batPoints.append(vec2)
	vec2 = origin
	vec2.x += bat.sweet_spot
	vec2.y -= height
	batPoints.append(vec2)
	vec2 = origin
	vec2.x -= length - bat.sweet_spot
	vec2.y += height
	batPoints.append(vec2)
	vec2 = origin
	vec2.x -= length - bat.sweet_spot
	vec2.y -= height
	batPoints.append(vec2)
	#fuck dis shit^^^^
	print("batPoints are: ", batPoints)
	return batPoints

func rotateBatFuction(batPoints: Array, Angle: float, target: Vector2):
	var origin = target
	Angle = Angle * (PI/180)
	for i in batPoints.size():
		var vec2 = batPoints[i]
		vec2 -= target
		vec2.x = (vec2.x * cos(Angle)) - (vec2.y * sin(Angle))
		vec2.y = (vec2.y * cos(Angle)) + (vec2.x * sin(Angle))
		vec2 += target
		batPoints[i] = vec2
	print("Angled bat is: ",batPoints)
	return batPoints

func doesBallHitBat(pointsIn: Array, target: Vector2):
	if Geometry2D.is_point_in_polygon(target,pointsIn):
		print("HIT")
	else:
		print("STRIKE")
