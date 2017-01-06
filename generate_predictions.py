"""
Call with a string giving the Fanduel csv, the season year, week and type (Regular or Postseason) 
Outputs a pickled dictionary with estimators for each position (except defense).  Also updates 
predicted scores table in the database.
"""

from __future__ import print_function, division
from sqlalchemy import create_engine
from process_fd_csv import get_current_predictors, random_forest_predict, write_fd_table, get_players_and_dates

import numpy as np
import pandas as pd
import pickle
import sys

engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
write_fd_table(get_players_and_dates(sys.argv[1]))

df = pd.read_sql("SELECT * FROM training_data", engine)
df.loc[df.position == 'FB', 'position'] = 'RB'

# Fix: current year, week, and season should be given as command
# line arguments, and the Fanduel csv should be given as well
# (currently also hard coded in fd_csv.py

# also fix, the main query is averaging over weeks with fd_score = 0
# which probably includes some players that didn't play (or just
# did trivial things like placehold on kicks)

predict_df = get_current_predictors(int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]) 
predict_df['predicted_score'] = np.nan

positions = ['QB', 'RB', 'WR', 'TE', 'K']
estimator_dict = {}
for position in positions:
    estimator_dict[position] = random_forest_predict(position, df, predict_df)

pickle.dump(estimator_dict, 'estimators.pkl')
relevant_cols = ['full_name', 'position', 'salary', 'predicted_score']
predict_df = predict_df[relevant_cols]
predict_df.to_sql('predicted_scores', con=engine, if_exists='replace')
