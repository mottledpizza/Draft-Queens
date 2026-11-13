extends Node
class_name base_team

@export var pitcher: base_player
@export var batting_order: base_player

func getPitcher():
	return pitcher

func getCurrentBatter():
	return batting_order
