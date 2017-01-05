from __future__ import print_function, division
from sqlalchemy import create_engine
from process_fd_csv import get_current_predictors, random_forest_predict

import numpy as np
import pandas as pd


engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
df = pd.read_sql("SELECT * FROM training_data", engine)
df.loc[df.position == 'FB', 'position'] = 'RB'

# Fix: current year, week, and season should be given as command
# line arguments, and the Fanduel csv should be given as well
# (currently also hard coded in fd_csv.py

# also fix, the main query is averaging over weeks with fd_score = 0
# which probably includes some players that didn't play (or just
# did trivial things like placehold on kicks)

predict_df = get_current_predictors(2016, 16, 'Regular') 
predict_df['predicted_score'] = np.nan

positions = ['QB', 'RB', 'WR', 'TE', 'K']
for position in positions:
    random_forest_predict(position, df, predict_df)

relevant_cols = ['full_name', 'position', 'salary', 'predicted_score']
predict_df = predict_df[relevant_cols]
predict_df.to_sql('predicted_scores', con=engine, if_exists='replace')
