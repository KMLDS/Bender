-- in lieu of actual defense predictions you can use the
-- season average ppg provided by fanduel so full lineups can be created
SELECT
	qb.full_name,
	qb.POSITION,
	qb.salary,
	qb.predicted_score,
	rb1.full_name,
	rb1.POSITION,
	rb1.salary,
	rb1.predicted_score,
	rb2.full_name,
	rb2.POSITION,
	rb2.salary,
	rb2.predicted_score,
	wr1.full_name,
	wr1.POSITION,
	wr1.salary,
	wr1.predicted_score,
	wr2.full_name,
	wr2.POSITION,
	wr2.salary,
	wr2.predicted_score,
	wr3.full_name,
	wr3.POSITION,
	wr3.salary,
	wr3.predicted_score,
	te.full_name,
	te.POSITION,
	te.salary,
	te.predicted_score,
	k.full_name,
	k.POSITION,
	k.salary,
	k.predicted_score,
	d.full_name,
	d.POSITION,
	d.salary,
	d.fppg,
	(qb.predicted_score + rb1.predicted_score + rb2.predicted_score + wr1.predicted_score + wr2.predicted_score + wr3.predicted_score + te.predicted_score + k.predicted_score + d.fppg) AS total_score,
	(qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary + te.salary + k.salary + d.salary) AS total_salary

FROM predicted_scores AS qb
CROSS JOIN predicted_scores AS rb1
INNER JOIN predicted_scores AS rb2 ON rb2.full_name <> rb1.full_name
      AND rb2.predicted_score <= rb1.predicted_score
CROSS JOIN predicted_scores AS wr1
INNER JOIN predicted_scores AS wr2 ON wr2.full_name <> wr1.full_name
      AND wr2.predicted_score <= wr1.predicted_score
INNER JOIN predicted_scores AS wr3 ON wr3.full_name <> wr2.full_name
      AND wr3.full_name <> wr1.full_name
      AND wr3.predicted_score <= wr2.predicted_score
CROSS JOIN predicted_scores AS te
CROSS JOIN predicted_scores AS k
CROSS JOIN fd_current AS d

WHERE qb.POSITION = 'QB'
      AND rb1.POSITION = 'RB'
      AND rb2.POSITION = 'RB'
      AND wr1.position = 'WR'
      AND wr2.POSITION = 'WR'
      AND wr3.POSITION = 'WR'
      AND te.POSITION = 'TE'
      AND k.POSITION = 'K'
      AND d.POSITION = 'D'
      AND qb.predicted_score > 12
      AND rb1.predicted_score > 10
      AND rb2.predicted_score > 8
      AND wr1.predicted_score > 10
      AND wr2.predicted_score > 9
      AND wr3.predicted_score > 7
      AND te.predicted_score > 6
      AND k.predicted_score > 8
      AND d.fppg > 7
      AND (qb.predicted_score + rb1.predicted_score + rb2.predicted_score + wr1.predicted_score + wr2.predicted_score + wr3.predicted_score + te.predicted_score + k.predicted_score + d.fppg) > 115
      AND (qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary + te.salary + k.salary + d.salary) <= 60000     
ORDER BY total_score DESC, total_salary DESC;
