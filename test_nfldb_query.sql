SELECT player.full_name, player.position, game.home_team, game.away_team, game.start_time, agg_player_games.*
FROM player
INNER JOIN 
	(SELECT play.pos_team AS "player_team", play_player.gsis_id, play_player.player_id, SUM(passing_tds) AS "passing_tds", SUM(passing_cmp) AS "passing_cmp", SUM(receiving_rec) AS "receiving_rec", SUM(rushing_att) AS "rushing_att"
	 FROM play_player
     INNER JOIN play
     	ON play_player.gsis_id = play.gsis_id 
     		AND play_player.play_id = play.play_id
	 GROUP BY player_id, play_player.gsis_id, play.pos_team
     HAVING SUM(passing_cmp) > 0) AS agg_player_games
     	ON player.player_id = agg_player_games.player_id
INNER JOIN game
	ON game.gsis_id = agg_player_games.gsis_id
WHERE player.position = 'QB'
	AND game.season_type = 'Regular'
