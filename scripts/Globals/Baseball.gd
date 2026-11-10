extends Node

const STRIKE_ZONE = Vector3(17,0,17)
const Strike_zone_height_percent = .295
#measured in inches
const FROM_PITCHER_T_BATTER = 766
const PITCHER_MOUNT_HEIGHT = 10
#regulation baseballs below! 
#in inches
const BALL_DIAMETER = 2.9
#in ounces
const BALL_WEIGHT = 5.1



func get_strikezone(height: int):
	var strikezone = STRIKE_ZONE
	strikezone.y = (height * Strike_zone_height_percent)
	return strikezone
