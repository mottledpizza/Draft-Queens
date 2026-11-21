extends Control

@export var team_1: base_team
@export var team_2: base_team

var rng = RandomNumberGenerator.new()
var strike_zone: Vector3
var ball_target: Vector2
var pitch_speed: float
var thrown_pitch: String

func _ready() -> void:
	SignalBus.StartGame.connect(playDaGame)
	playDaGame()

func playDaGame():
	var target = Pitch()
	Bat(target)
	

func Pitch():
	thrown_pitch = select_pitch()
	if LogConfig.pitch_config == true:
		print(thrown_pitch)
	
	strike_zone = Baseball.get_strikezone(team_2.getCurrentBatter().height)
	if LogConfig.pitch_config == true:
		print(strike_zone)
	var target = Vector2.ZERO
	target.x = rng.randf_range(-(strike_zone.x/2) + 2,(strike_zone.x/2) + 2)
	target.y = rng.randf_range(-(strike_zone.y/2) + 2,(strike_zone.y/2) + 2)
	
	var gravity = calc_grav(thrown_pitch, team_1.getPitcher().pitching_speeds[thrown_pitch])
	var projected_target = target + gravity - get_pitch_spin(thrown_pitch,team_1.getPitcher().pitching_sauce)
	ball_target = projected_target
	projected_target = throw(projected_target, thrown_pitch)
	if LogConfig.pitch_config == true:
		print("The Ball is Going Here! ",projected_target)
	return projected_target


func Bat(target: Vector2) -> void:
	#i/s -> i/ms
	#planning to expand this later
	var bat_speed = team_2.getCurrentBatter().bat_speed
	var time_to_react = 766 / ((pitch_speed * 17.6)/1000)
	time_to_react = time_to_react - ((team_2.getCurrentBatter().swing_length * 12) / (( bat_speed * 17.6)/1000)) - 125
	var can_react = false
	if time_to_react > team_2.getCurrentBatter().reaction_speed:
		can_react = true
	var guessed_pitch = predictPitch(can_react)
	if LogConfig.bat_config == true:
		print(guessed_pitch)
	swingBat(guessed_pitch, 766 / ((pitch_speed * 17.6)/1000), target, pitch_speed, bat_speed)
	

	

#IMPORTANT: DAVID! put the formula in this func pretty please
func calcBatPhysics(bat_x_angle: float, bat_y_angle: float, tilt: float, ball_height: float, bat_height: float, ball_diameter: float, bat_diameter: float, 
ball_mass: float, bat_mass:float, ball_velocity: float, bat_velocity: float, bat_length: float, bat_cap: Vector2, bat_tip: Vector2,bat_sweet_spot: float, ball_z_cord: float, coefficient_of_restitution: float = 0.4):
	var final_ball_velocity
	#bunch o nonsense, kill it all when you put in the equasion (womp womp too many typos)
	if LogConfig.bat_config == true:
		print("Bat X Angle is: ", bat_x_angle)
		print("Bat Tilt is: ", tilt)
		#bat y angle is tilt
		print("Ball Height is: ", ball_height)
		print("Bat Height is: ", bat_height)
		print("Ball Diameter is: ", ball_diameter)
		print("Bat Diameter is: ", bat_diameter)
		print("Ball Mass is: ", ball_mass)
		print("Bat Mass is: ", bat_mass)
		print("Ball Velocity is: ",ball_velocity)
		print("Bat Velocity is: ", bat_velocity)
		#velocity is at sweet spot
		print("Bat Length is: ", bat_length)
	# new Variables!
		print("Bat Y Angle is: ", bat_y_angle)
		print("Bat Butt is: ", bat_cap)
		print("bat Tip is: ", bat_tip)
		print("Sweet Spot is:", bat_sweet_spot)
	#vectorize ball velocity
	var ball_initial_velocity = Vector3(-ball_velocity, 0, 0)
	
	#build ball vector
	#x is z here lo
	var ball_yz_point = Vector2(ball_z_cord, ball_height)

	#derive bat length as line equation
	# form is y - bat_slope * x + constant = 0
	var bat_slope = -1*(bat_tip.y - bat_cap.y)/(bat_tip.x - bat_cap.x)
	var constant = (-1* bat_slope * bat_cap.x) - bat_cap.y
	
	#find closest bat point on the yz plane
	var bat_collision_point = Geometry2D.get_closest_point_to_segment(ball_yz_point,bat_tip,bat_cap)
	var collision_yz_distance = bat_collision_point.distance_to(ball_yz_point)
	
	#calculate linear velocity of bat at point of collision
	var bat_angular_velocity = bat_velocity / bat_sweet_spot
	var initial_bat_linear_velocity = bat_angular_velocity * bat_collision_point.distance_to(bat_cap)
	var bat_normalized_velocity_vector = Vector3(cos(bat_x_angle) * cos(tilt),sin(tilt), sin(bat_x_angle) * cos(tilt))
	
	#PLACEHOLDER: not using angular stuff
	var bat_initial_velocity = bat_velocity * bat_normalized_velocity_vector
	
	#check for hit
	if (collision_yz_distance >= (ball_diameter+bat_diameter)):
		print("collision_yz_distance: ", collision_yz_distance)
		#STRIKE
		final_ball_velocity = ball_initial_velocity
		if LogConfig.bat_config == true:
			print("ERROR: strike according to the hitting formula")
			print("final_ball_velocity: ", final_ball_velocity)
		return Vector3(-ball_velocity, 0, 0)
	
	# construct collision vector
	var collision_x_angle = acos(collision_yz_distance/(bat_diameter+ball_diameter))
	var collision_yz_vector = ball_yz_point - bat_collision_point
	var collision_x_component = sqrt(pow((bat_diameter+ball_diameter), 2) - pow(collision_yz_distance, 2))
	var collision_vector = Vector3(collision_x_component, collision_yz_vector.y, collision_yz_vector.x).normalized()
	
	# construct collision plane
	var collision_plane = Plane(collision_vector)
	
	#find hit aligned velocity of bat and ball (only velocity that affects collision)
	var ball_hit_normal_velocity = collision_plane.project(ball_initial_velocity)
	var bat_hit_normal_velocity = collision_plane.project(bat_initial_velocity)
	var bat_hit_aligned_initial_velocity = (bat_initial_velocity - bat_hit_normal_velocity).length()
	var ball_hit_aligned_initial_velocity = -1*(ball_initial_velocity - ball_hit_normal_velocity).length()

	#calculate final ball hit aligned velocity
	var ball_hit_aligned_final_velocity = ((bat_mass*bat_hit_aligned_initial_velocity) + (ball_mass*ball_hit_aligned_initial_velocity) + (bat_mass*coefficient_of_restitution*(bat_hit_aligned_initial_velocity-ball_hit_aligned_initial_velocity)))/(bat_mass+ball_mass)
	
	#okay time to reconstruct the velocity from its constituent parts
	
	final_ball_velocity = (ball_hit_aligned_final_velocity * collision_vector) + ball_hit_normal_velocity

	if LogConfig.bat_config == true:
			print("hit")
			print("bat collision point: ", bat_collision_point)
			print("collision_vector: ", collision_vector)
			print("ball_initial_velocity: ", ball_initial_velocity)
			print("bat_initial_velocity: ", bat_initial_velocity)
			print("bat_hit_aligned_initial_velocity: ", bat_hit_aligned_initial_velocity)
			print("ball_hit_aligned_initial_velocity: ", ball_hit_aligned_initial_velocity)
			print("ball_hit_aligned_final_velocity: ", ball_hit_aligned_final_velocity)
			print("ball_hit_normal_velocity: ", ball_hit_normal_velocity)
			print("final_ball_velocity: ", final_ball_velocity)
	return final_ball_velocity

func swingBat(guessed_pitch: String, ball_time: float,ball_strike_point, pitch_speed: float, bat_speed: float):
	var target = Vector2.ZERO
	target = ball_target + get_pitch_spin(guessed_pitch, team_1.getPitcher().pitching_sauce) - calc_grav(guessed_pitch,pitch_speed)
	if LogConfig.bat_config == true:
		print("I'm Gonna Hit Here! ", target)
	var predicted_time_to_hit = snapped(rng.randfn(team_1.getPitcher().pitching_speeds[guessed_pitch], 2.0), 0.01)
	predicted_time_to_hit = 766 / ((predicted_time_to_hit * 17.6)/1000)
	if LogConfig.bat_config == true:
		print("time to hit: ",predicted_time_to_hit)
		print("ball time: ", ball_time)
	
	var batPoints: Array
	var angles: PackedFloat32Array
	if (predicted_time_to_hit - ball_time) < 0:
		#fyi it technically should be based off of the speed of the swing and the ball but uhhh i don't really care :P
		var distance_offset = (ball_time - predicted_time_to_hit)/2
		angles = batRot(predicted_time_to_hit,distance_offset,target)
		batPoints = createBatPoints(target)
		batPoints = rotateBatFuction(batPoints,angles[1], target)
		if LogConfig.bat_config == true:
			print("Swing is faster")
	elif (predicted_time_to_hit - ball_time) > 0:
		var distance_offset = (predicted_time_to_hit - ball_time)/2
		angles = batRot(predicted_time_to_hit,-distance_offset,target)
		batPoints = createBatPoints(target)
		batPoints = rotateBatFuction(batPoints,angles[1], target)
		if LogConfig.bat_config == true:
			print("Ball is faster!")
	elif (predicted_time_to_hit - ball_time) == 0:
		#statistically impossible... but just in case 
		if LogConfig.bat_config == true:
			print("Perfect!")
	if doesBallHitBat(batPoints, ball_strike_point):
		#WARNING got a random error here!!! no idea why needs checking
		calcBatPhysics(angles[0],angles[1],angles[2],ball_strike_point.y,target.y,Baseball.BALL_DIAMETER,team_2.getCurrentBatter().getBat().bat_diameter,
		Baseball.BALL_WEIGHT,team_2.getCurrentBatter().getBat().bat_weight, pitch_speed, bat_speed, team_2.getCurrentBatter().getBat().bat_length,
		(batPoints[2] + batPoints[3])/2, (batPoints[0] + batPoints[1])/2, team_2.getCurrentBatter().getBat().sweet_spot,ball_strike_point.x)

#gets the bat X angle
func batRot(time_to_hit: float, offset: float, target: Vector2):
	var bat_speed = team_2.getCurrentBatter().swing_length / time_to_hit
	var new_distance = (bat_speed * offset) * 12
	var diamiter = team_2.getCurrentBatter().getBat().bat_length * 2
	var rads_x = new_distance / (diamiter/2)
	var bat_height = team_2.getCurrentBatter().height
	bat_height = (bat_height *.48) + (target.y / 10)
	print("Bat height is here: ",bat_height)
	var rads_y = atan2(bat_height - target.y,target.x + 17 + team_2.getCurrentBatter().distance_from_plate)
	var tilt = ((team_2.getCurrentBatter().tilt * (PI/180)) + rng.randf_range(-0.0872664626,0.0872664626)) - rads_x
	
	var angles_out: PackedFloat32Array
	angles_out.append(rads_x)
	angles_out.append(rads_y)
	angles_out.append(tilt )
	if LogConfig.bat_config == true:
		print("Y Rads ", angles_out[1])
		print("Tilt ", angles_out[2])
		print("X Rads ", angles_out[0])
	return angles_out

func predictPitch(can_react: bool ):
	var predicted_pitch: String
	if !can_react: 
		predicted_pitch = select_pitch()
	else:
		predicted_pitch = select_pitch(thrown_pitch, team_2.getCurrentBatter().batting_compitence)
	return predicted_pitch


func throw(target: Vector2,thrown_pitch: String):
	pitch_speed = snapped(rng.randfn(team_1.getPitcher().pitching_speeds[thrown_pitch], 2.0), 0.01)
	var inches_per_sec = pitch_speed * 17.6
	
	#calc the accuracy of the throw
	var accuracy = 1 - team_1.getPitcher().accuracy/100
	target.x = target.x + rng.randf_range(-(abs(target.x * accuracy) + (pitch_speed - 60)/10),abs(target.x * accuracy) + (pitch_speed - 60)/10)
	target.y = target.y + rng.randf_range(-(abs(target.y * accuracy) + (pitch_speed - 60)/10),abs(target.y * accuracy) + (pitch_speed - 60)/10)
	
	target = target + get_pitch_spin(thrown_pitch, rng.randfn(team_1.getPitcher().pitching_sauce)) - calc_grav(thrown_pitch,pitch_speed)
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
	if team_1.getPitcher().pitch_dominant_hand == "R":
		return pitch_type_info["R_Pitch"] * (pitch_sauce/100)
	if team_1.getPitcher().pitch_dominant_hand == "L":
		return pitch_type_info["L_Pitch"] * (pitch_sauce/100)

#takes the perfered pitches in the player script and connects them to the pitch arsenals to select a pitch
func select_pitch(thrown_pitch: String = "null", competence: float = 0.0 ):
	var pitcher_arsenal: Array = team_1.getPitcher().pitching_arsenal.duplicate()
	var pitch_weights: PackedFloat32Array
	
	#set the weights for all of the perfered pitches
	for i in pitcher_arsenal.size():
		if thrown_pitch == pitcher_arsenal[i]:
			pitch_weights.append(team_1.getPitcher().perfered_pitches[pitcher_arsenal[i]] * (((competence/2)/100) + 1 ))
		else:
			pitch_weights.append(team_1.getPitcher().perfered_pitches[pitcher_arsenal[i]])
	return pitcher_arsenal[rng.rand_weighted(pitch_weights)]

func getWhereBallThrownFrom():
	var gravity = calc_grav(thrown_pitch, team_1.getPitcher().pitching_speeds[thrown_pitch])
	var spot_thrown_from = ball_target - gravity + get_pitch_spin(thrown_pitch,team_1.getPitcher().pitching_sauce)
	return spot_thrown_from
	
func createBatPoints(target: Vector2):
	var bat: base_bat
	bat = team_2.getCurrentBatter().getBat()
	var height = bat.bat_diameter / 2
	var length = bat.bat_length
	var origin = target
	var vec2: Vector2
	#array is formated that 0 is the top of the tip, 1 is the bottom of the tip
	#2 is top of handle 3 is bottom of handle
	var bat_points = []
	var baseball_radius = Baseball.BALL_DIAMETER/2
	vec2 = origin
	vec2.x += bat.sweet_spot
	vec2.y -= height
	vec2 += Vector2(baseball_radius,-baseball_radius)
	bat_points.append(vec2)
	vec2 = origin
	vec2.x += bat.sweet_spot
	vec2.y += height
	vec2 += Vector2(baseball_radius,baseball_radius)
	bat_points.append(vec2)
	vec2 = origin
	vec2.x -= length - bat.sweet_spot
	vec2.y += height
	vec2 += Vector2(-baseball_radius,baseball_radius)
	bat_points.append(vec2)
	vec2 = origin
	vec2.x -= length - bat.sweet_spot
	vec2.y -= height
	vec2 += Vector2(-baseball_radius,-baseball_radius)
	bat_points.append(vec2)
	#fuck dis shit^^^^
	if LogConfig.bat_config == true:
		print("bat_points are: ", bat_points)
	return bat_points

func rotateBatFuction(bat_points: Array, Angle: float, target: Vector2):
	var origin = target
	Angle = -Angle
	for i in bat_points.size():
		var vec2 = bat_points[i]
		var vectemp = Vector2.ZERO
		vec2 -= target
		vectemp.x = (vec2.x * cos(Angle)) - (vec2.y * sin(Angle))
		vectemp.y = (vec2.x * sin(Angle)) + (vec2.y * cos(Angle))
		vectemp += target
		bat_points[i] = vectemp
	if LogConfig.bat_config == true:
		print("Angled bat is: ",bat_points)
	return bat_points

func doesBallHitBat(points_in: PackedVector2Array, target: Vector2):
	if Geometry2D.is_point_in_polygon(target,points_in):
		print("HIT")
	else:
		print("STRIKE")
	return Geometry2D.is_point_in_polygon(target,points_in)
