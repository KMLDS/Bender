# Usage

This project is still in fairly raw form, however here are steps to get it up and running from scratch:

1. Install [nfldb](https://github.com/BurntSushi/nfldb) (instructions available [here](https://github.com/BurntSushi/nfldb/wiki/Installation))
2. It is a good idea to run the `nfldb_update.py` script found in Bender right away, mainly to fix a bug in nfldb where Jacksonville is labeled both 'JAX' and 'JAC'.
3. Download a player list (.csv file) from a Fanduel contest.
4. Run the `generate_predictions.py` script with the syntax `python generate_predictions.py <fanduel_file> <season_year> <week> <season_type>` where the week refers to the *previous* week played and `season_type` is either Regular or Postseason.
5. Running `lineups.sql` in the `/sql/` folder (e.g. with `psql -U <nfldb_user> -d nfldb -f lineups.sql`) will generate a list of the lineups with the best possible predicted scores.

The above will add new tables and materialized views to nfldb.

Only Fanduel lineups and rules are currently implemented.  For reference, a typical best prediction for a given regular season lineup is about 140 points with a standard deviation of about 20 points.

**Note:** This info is mostly to serve as a reminder to me in case I accidentally trash my computer or similar and want to quickly rebuild.  Anyone who stumbles across this and wants to use it is welcome to, just realize the code is not polished (or even finished in some cases), and I guarantee nothing about performance (or anything else).

