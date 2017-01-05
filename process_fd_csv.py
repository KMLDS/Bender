from __future__ import print_function, division

import re
import pandas as pd
import numpy as np
from sklearn.model_selection import cross_val_score, RandomizedSearchCV
from sklearn.ensemble import GradientBoostingRegressor

# from sklearn.preprocessing import StandardScaler
# from sklearn.decomposition import PCA
# from sklearn.model_selection import KFold, RandomizedSearchCV, GridSearchCV
# from sklearn.linear_model import Ridge
# from sklearn.pipeline import Pipeline

from sqlalchemy import create_engine


def get_players_and_dates(csv_file):
    df = pd.read_csv(csv_file)
    df.columns = [x.replace(' ', '_').lower() for x in df.columns]
    df["full_name"] = df.first_name + ' ' + df.last_name
    df = df[~df['injury_indicator'].isin(['IR', 'O'])]
    relevant_cols = ['full_name', 'position', 'salary', 'team', 'opponent', 'fppg']
    df = df.loc[:, relevant_cols]
    return df


def write_fd_table(df):
    engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
    df.to_sql(name="fd_current", con=engine, if_exists='replace')


def get_current_predictors(season_year, week, season_type):
    query_file = open('query_current_predictors.sql', 'r')
    query_string = query_file.read()
    query_string = re.sub(r'[\n\t]', ' ', query_string)
    engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
    df = pd.read_sql(query_string.format(season_year, week, season_type),
                     engine)
    return df


def random_forest_predict(position, df, predict_df):
    X = df[df.position == position]
    y = df.loc[df.position == position, 'fd_score']
    X = X.iloc[:, 13:].fillna(0)
    param_dist = {'n_estimators': [50, 100, 150, 200, 300, 400, 500, 600],
                  'learning_rate': np.logspace(-3, 0, 8),
                  'max_depth': np.arange(1, 10, 1),
                  'max_features': ['auto', 'sqrt']}

    gbr = GradientBoostingRegressor()
    estimator = RandomizedSearchCV(estimator=gbr, param_distributions=param_dist, scoring='r2', n_jobs=-1, n_iter=600)
    estimator.fit(X, y)
    print(position + ':')
    print('Best score: ' + str(estimator.best_score_))
    print('Best parameters: ' + str(estimator.best_params_))


    predict_X = predict_df[predict_df.position == position]
    predict_X = predict_X.iloc[:, 6:-1]
    predict_y = estimator.predict(predict_X)
    predict_df.loc[predict_df.position == position, 'predicted_score'] = predict_y
    print('Training data shape: ' + str(X.shape))
    print('Predction data shape: ' + str(predict_X.shape) + '\n')


# def ridge_predict(position, df=df, predict_df=predict_df):
#     X = df[df.position == position]
#     y = df.loc[df.position == position, 'fd_score']
#     X = X.iloc[:, 13:].fillna(0)
#     scaler = StandardScaler()
#     pca = PCA()
#     ridge = Ridge()
#     #lr = LinearRegression()
#     kfold = KFold(n_splits=5, shuffle=True)
#     pipe = Pipeline(steps=[('scaler', scaler), ('pca', pca), ('ridge', ridge)])
#     # param_dist = {'pca__n_components': sp.stats.poisson(150),
#     #               'ridge__alpha': sp.stats.poisson(130)}
#     #    pipe = Pipeline(steps=[('scaler', scaler), ('pca', pca), ('lr', lr)])
#     #    param_dist = {'pca__n_components': sp.stats.poisson(mu=150)}

#     #    random_cv = RandomizedSearchCV(pipe, param_distributions=param_dist, cv=kfold, n_jobs=-1, n_iter=5)
#     #    random_cv.fit(X, y)
#     param_dict = {'pca__n_components': [150],
#                   'ridge__alpha': [130]}
#     grid_cv = GridSearchCV(estimator=pipe, param_grid=param_dict, cv=kfold, n_jobs=-1)
#     grid_cv.fit(X, y)
#     print('Position: ' + str(position) + '\n')
#     print('Best parameters: ' + str(grid_cv.best_params_) + '\n')
#     print('Best score: ' + str(grid_cv.best_score_) + '\n\n')

#     predict_X = predict_df[predict_df.position == position]
#     predict_X = predict_X.iloc[:, 6:-1]
#     predict_y = grid_cv.predict(predict_X)
#     predict_df.loc[predict_df.position == position, 'predicted_score'] = predict_y
#     print(X.shape)
#     print(predict_X.shape)


# write_fd_table(get_players_and_dates(
# "FanDuel-NFL-2017-01-01-17431-players-list.csv"))
# print(get_current_predictors(2016, 16, "Regular"))
