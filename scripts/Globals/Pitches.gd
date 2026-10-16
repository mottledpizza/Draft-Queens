extends Node

var Four_Seamer: Dictionary = {"pitch_name": "4-Seamer", "R_Pitch": Vector2(7.8,15.9), 
"L_Pitch": Vector2(-7.8,15.7)}

var Slider_Pitch: Dictionary = {"pitch_name": "Slider", "R_Pitch": Vector2(-3.7,1.4), 
"L_Pitch": Vector2(4.4,1.4)}

var Sinker: Dictionary = {"pitch_name": "Sinker", "R_Pitch": Vector2(-3.7,1.2), 
"L_Pitch": Vector2(-15.5,7.7)}

var Cutter: Dictionary = {"pitch_name": "Cutter", "R_Pitch": Vector2(-2.2, 8.1), 
"L_Pitch": Vector2(2.1, 7.5)}

var Change_up: Dictionary = {"pitch_name": "Change Up", "R_Pitch": Vector2(14.4,3.9), 
"L_Pitch": Vector2(-13.9,5.0)}

var Curve_Pitch: Dictionary = {"pitch_name": "Curve", "R_Pitch": Vector2(-9.2,-10.2), 
"L_Pitch": Vector2(7.2, -10.0)}

var Splitter: Dictionary = {"pitch_name": "Splitter", "R_Pitch": Vector2(11.5, 3.0), 
"L_Pitch": Vector2(-9.4, 4.8)}

var Sweeper: Dictionary = {"pitch_name": "Sweeper", "R_Pitch": Vector2(-13.8, 1.0), 
"L_Pitch": Vector2(13.7, 0.6)}

var Slurve: Dictionary = {"pitch_name": "Slurve", "R_Pitch": Vector2(-11.1,-6.9), 
"L_Pitch": Vector2(12.4,-4.2)}

#Guh, I hate this kinda shit but I really don't know a better way
func get_pitch_dic(pitch: String):
	if pitch == Four_Seamer["pitch_name"]:
		return Four_Seamer
	if pitch == Slider_Pitch["pitch_name"]:
		return Slider_Pitch
	if pitch == Sinker["pitch_name"]:
		return Sinker
	if pitch == Cutter["pitch_name"]:
		return Cutter
	if pitch == Change_up["pitch_name"]:
		return Change_up
	if pitch == Curve_Pitch["pitch_name"]:
		return Curve_Pitch
	if pitch == Splitter["pitch_name"]:
		return Splitter
	if pitch == Sweeper["pitch_name"]:
		return Sweeper
	if pitch == Slurve["pitch_name"]:
		return Slurve
	
