from sqlalchemy import create_engine
import re
import pandas as pd


def get_players_and_dates(csv_file):
    df = pd.read_csv(csv_file)
    df.columns = [x.replace(' ', '_').lower() for x in df.columns]
    df["full_name"] = df.first_name + ' ' + df.last_name
    df = df[~df['injury_indicator'].isin(['IR', 'O'])]
    relevant_cols = ['full_name', 'position', 'salary', 'team', 'opponent']
    df = df.loc[:, relevant_cols]
    return df

def write_fd_table(df):
    engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
    df.to_sql(name="fd_current", con=engine, if_exists='replace')

def get_current_predictors(season_year, week, season_type):
    query_file = open('query_current_predictors.sql', 'r')
    query_string = query_file.read()
    query_string = re.sub(r'[\n\t]', ' ', query_string) # clean all newlines and tabs out of string
    engine = create_engine("postgresql://nfldb:nfldb@localhost:5432")
    df = pd.read_sql(query_string, engine)
    return df
    
# write_fd_table(get_players_and_dates("FanDuel-NFL-2017-01-01-17431-players-list.csv"))
