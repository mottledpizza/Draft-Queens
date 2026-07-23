extends base_player
#WARNING: THIS SCRIPT IS FOR TESTING PURPOSESES ONLY!!!
#remove me from the game once mother script is made

func _init() -> void:
	player_name = "Jesus Luzardo"
	height = 72
	age = 28
	
	pitch_dominant_hand = "L"
	pitching_arsenal = ["Sweeper","4-Seamer","Change Up", "Sinker"]
	accuracy = 90.0
	pitching_sauce = 95.0
	
	pitching_speeds["Sweeper"] = 86.4
	pitching_speeds["4-Seamer"] = 97.1
	pitching_speeds["Change Up"] = 86.3
	pitching_speeds["Sinker"] = 96.0
	
	perfered_pitches["Sweeper"] = 37
	perfered_pitches["4-Seamer"] = 25
	perfered_pitches["Change Up"] = 20
	perfered_pitches["Sinker"] = 18
