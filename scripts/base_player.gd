extends Node
class_name base_player
#human attributes 
var player_name: String
var height: float
var age: int




#pitching attributes
var pitch_dominant_hand: String
var pitching_arsenal: Array
var accuracy: float
#the amount of spin the player is able to put on the ball
var pitching_sauce: float
var pitching_speeds = {
	# average speed is 95 high of 100
	"4-Seamer": 0.0,
	
	# average speed is 95 high of 100
	"Sinker": 0.0,
	
	# average speed is 90 high of 96
	"Cutter": 0.0,
	
	# average speed is 87 high of 92
	"Slider": 0.0,
	
	# average speed is 87 high of 96
	"Change Up": 0.0,
	
	# average speed is 80 high of 90
	"Curve": 0.0,
	
	# average speed is 87 high of 96
	"Splitter": 0.0,
	
	# average speed is 83 high of 88
	"Sweeper": 0.0,
	
	# average speed is 82 high of 85
	"Slurve": 0.0
}
var perfered_pitches = {
	"4-Seamer": 0,
	"Sinker": 0,
	"Cutter": 0,
	"Slider": 0,
	"Change Up": 0,
	"Curve": 0,
	"Splitter": 0,
	"Sweeper": 0,
	"Slurve": 0
}


#Batting stats
#perfered bat:
#wood required by mlb, common ones being Maple, Ash, and Birch
var bat_material: String
#in ounces, averages 31-34 depending on height
var bat_weight: int
#in inches, averages 32 to 34
var bat_length: int
#in inches, maximum 2.61
var bat_diameter: float
#player stats
#in feet, average of 7.3, goes from 4 to 10
var swing_length: float
#in mph the longer the length the faster the swing generally.
var bat_speed: float
#in milliseconds 
var reaction_speed: int 
#a percentage, can go over 100, increases the chance to predict what ball is being thrown
var batting_compitence: float
