from __future__ import print_function, division
from sqlalchemy import create_engine
from process_fd_csv import *

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.model_selection import KFold, RandomizedSearchCV, GridSearchCV
from sklearn.linear_model import Ridge, LinearRegression
from sklearn.pipeline import Pipeline

import numpy as np
import pandas as pd
import scipy as sp


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

print(df.columns)
print(predict_df.columns)

def predict_position(position, df=df, predict_df=predict_df):
    X = df[df.position == position]
    y = df.loc[df.position == position, 'fd_score']
    X = X.iloc[:, 13:].fillna(0)
    scaler = StandardScaler()
    pca = PCA()
    ridge = Ridge()
    #lr = LinearRegression()
    kfold = KFold(n_splits=5, shuffle=True)
    pipe = Pipeline(steps=[('scaler', scaler), ('pca', pca), ('ridge', ridge)])
    # param_dist = {'pca__n_components': sp.stats.poisson(150),
    #               'ridge__alpha': sp.stats.poisson(130)}
    #    pipe = Pipeline(steps=[('scaler', scaler), ('pca', pca), ('lr', lr)])
    #    param_dist = {'pca__n_components': sp.stats.poisson(mu=150)}

    #    random_cv = RandomizedSearchCV(pipe, param_distributions=param_dist, cv=kfold, n_jobs=-1, n_iter=5)
    #    random_cv.fit(X, y)
    param_dict = {'pca__n_components': [150],
                  'ridge__alpha': [130]}
    grid_cv = GridSearchCV(estimator=pipe, param_grid=param_dict, cv=kfold, n_jobs=-1)
    grid_cv.fit(X, y)
    print('Position: ' + str(position) + '\n')
    print('Best parameters: ' + str(grid_cv.best_params_) + '\n')
    print('Best score: ' + str(grid_cv.best_score_) + '\n\n')

    predict_X = predict_df[predict_df.position == position]
    predict_X = predict_X.iloc[:, 6:-1]
    predict_y = grid_cv.predict(predict_X)
    predict_df.loc[predict_df.position == position, 'predicted_score'] = predict_y
    print(X.shape)
    print(predict_X.shape)

positions = ['QB', 'RB', 'WR', 'TE', 'K']
for position in positions:
    predict_position(position, df=df, predict_df=predict_df)

predict_df.to_sql('predicted_scores', con=engine, if_exists='replace')

