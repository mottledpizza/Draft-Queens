extends Node

var database : SQLite

func _ready():
	database = SQLite.new()
	database.path = "res://baseball_history.db"
	database.open_db()
	
	var teams_table = {
		"team_id" : {"data_type":"int", "primary_key": true, "auto_increment": true},
		"name" : {"data_type":"text"}
	}
	database.create_table("teams", teams_table)
	var games_table = {
		"game_id" : {"data_type":"int", "primary_key": true, "auto_increment": true},
		"visiting_team_id" : {"data_type":"int", "not_null": true, "foreign_key": "teams.team_id"},
		"home_team_id" : {"data_type":"int", "not_null": true, "foreign_key": "teams.team_id"},
		"season_no" : {"data_type":"int"},
		"conditions" : {"data_type":"text"}
	}
	database.create_table("games", games_table)
	var players_table = {
		"player_id" : {"data_type":"int", "primary_key": true, "auto_increment": true},
		"current_team_id" : {"data_type":"int", "not_null": true, "foreign_key": "teams.team_id"},
		"name" : {"data_type":"text"},
		"catchphrase" : {"data_type":"text", "default":"null"}
	}
	database.create_table("players", players_table)
	var game_performance_table = {
		"game_id" : {"data_type":"int", "not_null": true, "foreign_key": "games.game_id"},
		"player_id" : {"data_type":"int", "not_null": true, "foreign_key": "players.player_id"},
		"team_id" : {"data_type":"int", "not_null": true, "foreign_key": "teams.team_id"},
		"at_bat_performance" : {"data_type":"text"},
		"stats" : {"data_type":"text"}
	}
	database.create_table("game_performance", game_performance_table)
	
	database.close_db()
