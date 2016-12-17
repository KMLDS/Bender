-- appears there may be errors (e.g. gsis_id 2009091309 has ARI w/ 44 attempted passes and 26 completions but nfl.com
-- shows 29 and 16
WITH od AS(
      SELECT gsis_id,
       	     team,
       	     pos_team,
	     home_team,
	     away_team,
       	     SUM(defense_ast) AS team_defense_ast,
       	     SUM(defense_ffum) AS team_defense_ffum,
       	     SUM(defense_fgblk) AS team_defense_fgblk,
       	     SUM(defense_int) AS team_defense_int,
       	     SUM(defense_int_yds) AS team_defense_int_yds,
       	     SUM(defense_int_tds) AS team_defense_int_tds,
       	     SUM(defense_misc_tds) AS team_defense_misc_tds,
 	     SUM(defense_pass_def) AS team_defense_pass_def,
    	     SUM(defense_puntblk) AS team_defense_puntblk,
	     SUM(defense_qbhit) AS team_defense_qbhit,
	     SUM(defense_safe) AS team_defense_safe,
	     SUM(defense_sk) AS team_defense_sk,
	     SUM(defense_sk_yds) AS team_defense_sk_yds,
	     SUM(defense_tkl) AS team_defense_tkl,
	     SUM(defense_tkl_loss) AS team_defense_tkl_loss,

	     SUM(passing_att) AS team_passing_att,
       	     SUM(passing_cmp) AS team_passing_cmp,
	     SUM(passing_int) AS team_passing_int,
	     SUM(passing_tds) AS team_passing_tds,
	     SUM(passing_yds) AS team_passing_yds,

	     SUM(receiving_rec) AS team_receiving_rec,
	     SUM(receiving_tar) AS team_receiving_tar,
	     SUM(receiving_tds) AS team_receiving_tds,
	     SUM(receiving_yac_yds) AS team_receiving_yac_yds,
	     SUM(receiving_yds) AS team_receiving_yds,
	     SUM(rushing_att) AS team_rushing_att,
	     SUM(rushing_loss) AS team_rushing_loss,
	     SUM(rushing_tds) AS team_rushing_tds,
	     SUM(rushing_yds) AS team_rushing_yds	     
	     
      FROM (SELECT drive.pos_team, game.home_team, game.away_team, play_player.* FROM drive
      	    INNER JOIN play_player
	    ON drive.gsis_id = play_player.gsis_id
	       AND drive.drive_id = play_player.drive_id
	    INNER JOIN game
      	    ON drive.gsis_id = game.gsis_id
	    WHERE game.season_type = 'Regular') AS a
      GROUP BY gsis_id, team, pos_team, home_team, away_team),
ind AS (
    SELECT gsis_id,
    	   full_name,
	   POSITION,
	   start_time,
	   season_year,
	   week,
	   player_id,
    	   team,
	   home_team,
	   away_team,

	   SUM(fumbles_tot) AS ind_fumbles_tot,
	   SUM(fumbles_lost) AS ind_fumbles_lost,

	   SUM(kicking_fga) AS ind_kicking_fga,
	   SUM(kicking_fgm) AS ind_kicking_fgm,
	   SUM(kicking_fgm_yds) AS ind_kicking_fgm_yds, -- isn't useful as-is need to change to ordered categorical, i.e. 3 pts for fgm_yds <= 39 yds, 4 for fgm_yds between 39 and 49
	   SUM(kicking_fgmissed) AS ind_kicking_fgmissed,
	   SUM(kicking_fgmissed_yds) AS ind_kicking_fgmissed_yds,
	   SUM(kicking_xpa) AS ind_kicking_xpa,
	   SUM(kicking_xpmade) AS ind_kicking_xpmade,

	   SUM(kickret_ret) AS ind_kickret_ret,
	   SUM(kickret_tds) AS ind_kickret_tds,
	   SUM(kickret_yds) AS ind_kickret_yds,

	   SUM(passing_att) AS ind_passing_att,
	   SUM(passing_cmp) AS ind_passing_cmp,
	   SUM(passing_cmp_air_yds) AS ind_passing_cmp_air_yds,
	   SUM(passing_incmp) AS ind_passing_incmp,
	   SUM(passing_incmp_air_yds) AS ind_passing_incmp_air_yds,
	   SUM(passing_int) AS ind_passing_int,
	   SUM(passing_sk) AS ind_passing_sk,
	   SUM(passing_sk_yds) AS ind_passing_sk_yds,
	   SUM(passing_tds) AS ind_passing_tds,
	   SUM(passing_twopta) AS ind_passing_twopta,
	   SUM(passing_twoptm) AS ind_passing_twoptm,
	   SUM(passing_yds) AS ind_passing_yds,

	   SUM(puntret_tds) AS ind_puntret_tds,
	   SUM(puntret_tot) AS ind_puntret_tot,
	   SUM(puntret_yds) AS ind_puntret_yds,

	   SUM(receiving_rec) AS ind_receiving_rec,
	   SUM(receiving_tar) AS ind_receiving_tar,
	   SUM(receiving_tds) AS ind_receiving_tds,
	   SUM(receiving_twopta) AS ind_receiving_twopta,
	   SUM(receiving_twoptm) AS ind_receiving_twoptm,
	   SUM(receiving_yac_yds) AS ind_receiving_yac_yds,
	   SUM(receiving_yds) AS ind_receiving_yds,

	   SUM(rushing_att) AS ind_rushing_att,
	   SUM(rushing_loss) AS ind_rushing_loss,
	   SUM(rushing_loss_yds) AS ind_rushing_loss_yds,
	   SUM(rushing_tds) AS ind_rushing_tds,
	   SUM(rushing_twopta) AS ind_rushing_twopta,
	   SUM(rushing_twoptm) AS ind_rushing_twoptm,
	   SUM(rushing_yds) AS ind_rushing_yds,

	   -- need to fix here and above for kickers
	   (0.1*(SUM(rushing_yds) - SUM(rushing_loss_yds)) + 6.0*SUM(rushing_tds) + 0.04*SUM(passing_yds) + 4.0*SUM(passing_tds) - 1.0*SUM(passing_int)
	   + 0.1*SUM(receiving_yds) + 6.0*SUM(receiving_tds) + 0.5*SUM(receiving_rec) + 6.0*(SUM(kickret_tds) + SUM(puntret_tds)) - 2.0*SUM(fumbles_lost)
	   + 2.0*(SUM(passing_twoptm) + SUM(receiving_twoptm) + SUM(rushing_twoptm)) + 3.2*SUM(kicking_fgm) + 1.0*SUM(kicking_xpmade)) AS fd_score
	   
   FROM (SELECT play_player.*, player.full_name, player.POSITION, game.home_team, game.away_team, game.start_time, game.season_year, game.week
   	 FROM play_player
	 INNER JOIN player
	       ON play_player.player_id = player.player_id
	 INNER JOIN game
	       ON play_player.gsis_id = game.gsis_id
	 WHERE game.season_type = 'Regular') as b
   GROUP BY gsis_id, full_name, POSITION, start_time, season_year, week, player_id, team, home_team, away_team
--   HAVING fd_score > 0
)
SELECT
	def.gsis_id,
	ind.full_name,
	ind.POSITION,
	ind.start_time,
	ind.season_year,
	ind.week,
	ind.fd_score,
	ind.player_id,
	def.team,
	def.home_team,
	def.away_team,

	AVG(ind.ind_fumbles_tot) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_fumbles_tot,
	AVG(ind.ind_fumbles_lost) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_fumbles_lost,

	AVG(ind.ind_kicking_fga) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_fga,
	AVG(ind.ind_kicking_fgm) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_fgm,
	AVG(ind.ind_kicking_fgm_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_fgm_yds, -- fix w.r.t. kicking stats
	AVG(ind.ind_kicking_fgmissed) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_fgmissed,
	AVG(ind.ind_kicking_fgmissed_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_fgmissed_yds,
	AVG(ind.ind_kicking_xpa) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_xpa,
	AVG(ind.ind_kicking_xpmade) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kicking_xpmade,

	AVG(ind.ind_kickret_ret) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kickret_ret,
	AVG(ind.ind_kickret_tds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kickret_tds,
	AVG(ind.ind_kickret_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_kickret_yds,

	AVG(ind.ind_passing_att) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_att,
	AVG(ind.ind_passing_cmp) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_cmp,
	AVG(ind.ind_passing_cmp_air_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_cmp_air_yds,
	AVG(ind.ind_passing_incmp) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_incmp,
	AVG(ind.ind_passing_incmp_air_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_incmp_air_yds,
	AVG(ind.ind_passing_int) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_int,
	AVG(ind.ind_passing_sk) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_sk,
	AVG(ind.ind_passing_sk_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_sk_yds,
	AVG(ind.ind_passing_tds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_tds,
	AVG(ind.ind_passing_twopta) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_twopta,
	AVG(ind.ind_passing_twoptm) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_twoptm,
	AVG(ind.ind_passing_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_passing_yds,

	AVG(ind.ind_puntret_tds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_puntret_tds,
	AVG(ind.ind_puntret_tot) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_puntret_tot,
	AVG(ind.ind_puntret_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_puntret_yds,

	AVG(ind.ind_receiving_rec) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_rec,
	AVG(ind.ind_receiving_tar) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_tar,
	AVG(ind.ind_receiving_tds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_tds,
	AVG(ind.ind_receiving_twopta) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_twopta,
	AVG(ind.ind_receiving_twoptm) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_twoptm,
	AVG(ind.ind_receiving_yac_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_yac_yds,
	AVG(ind.ind_receiving_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_receiving_yds,

	AVG(ind.ind_rushing_att) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_att,
	AVG(ind.ind_rushing_loss) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_loss,
	AVG(ind.ind_rushing_loss_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_loss_yds,
	AVG(ind.ind_rushing_tds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_tds,
	AVG(ind.ind_rushing_twopta) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_twopta,
	AVG(ind.ind_rushing_twoptm) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_twoptm,
	AVG(ind.ind_rushing_yds) OVER(PARTITION BY ind.player_id ORDER BY ind.start_time ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_ind_rushing_yds, 

	AVG(def.team_defense_ast) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_ast,
	AVG(def.team_defense_ffum) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_ffum,
	AVG(def.team_defense_fgblk) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_fgblk,
	AVG(def.team_defense_int) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_int,
	AVG(def.team_defense_int_yds) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_int_yds,
	AVG(def.team_defense_int_tds) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_int_tds,
	AVG(def.team_defense_misc_tds) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_misc_tds,
	AVG(def.team_defense_pass_def) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_pass_def,
	AVG(def.team_defense_puntblk) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_puntblk,
	AVG(def.team_defense_qbhit) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_qbhit,
	AVG(def.team_defense_safe) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_safe,
	AVG(def.team_defense_sk) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_sk,
	AVG(def.team_defense_sk_yds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_sk_yds,
	AVG(def.team_defense_tkl) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_tkl,
	AVG(def.team_defense_tkl_loss) OVER(PARTITION BY def.team ORDER BY def.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_defense_tkl_loss,

	AVG(offense.team_passing_att) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_passing_att,
	AVG(offense.team_passing_cmp) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_passing_cmp,
	AVG(offense.team_passing_int) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_passing_int,
	AVG(offense.team_passing_tds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_passing_tds,
	AVG(offense.team_passing_yds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_passing_yds,

	AVG(offense.team_receiving_rec) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_receiving_rec,
	AVG(offense.team_receiving_tar) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_receiving_tar,
	AVG(offense.team_receiving_tds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_receiving_tds,
	AVG(offense.team_receiving_yac_yds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_receiving_yac_yds,
	AVG(offense.team_receiving_yds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_receiving_yds,

	AVG(offense.team_rushing_att) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_rushing_att,
	AVG(offense.team_rushing_loss) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_rushing_loss,
	AVG(offense.team_rushing_tds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_rushing_tds,
	AVG(offense.team_rushing_yds) OVER(PARTITION BY offense.team ORDER BY offense.gsis_id ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) AS avg_rushing_yds

FROM od AS def
INNER JOIN od AS offense -- self join to combine rolling averages for offense and defense for a given team & gsis_id
ON def.gsis_id = offense.gsis_id
   AND def.team = offense.team
INNER JOIN ind
ON ind.gsis_id = offense.gsis_id
   AND ind.team = offense.team
WHERE def.team <> def.pos_team
   AND offense.team = offense.pos_team
   AND ind.fd_score > 0
   AND ind.POSITION <> 'UNK'
   AND ind.team <> 'UNK'
ORDER BY ind.POSITION ASC, ind.fd_score DESC;
