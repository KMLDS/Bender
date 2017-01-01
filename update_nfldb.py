from __future__ import print_function, division
import psycopg2
import os

conn_string = "host='localhost' dbname='nfldb' user='nfldb' password='nfldb'"
conn = psycopg2.connect(conn_string)
cursor = conn.cursor()

# the NFL data sometimes includes JAX instead of JAC and ruins everything,
#this allows JAX to be added
include_jax_string = "INSERT INTO team VALUES('JAX', 'Jacksonville', 'Jaguars');"
cursor.execute(include_jax_string)
conn.commit()

execfile("/home/kevin/virtualenvs/bender/bin/nfldb-update")


update_string = "UPDATE play SET pos_team = 'JAC' WHERE pos_team = 'JAX'"
cursor.execute(update_string)
delete_string = "DELETE FROM team WHERE team_id = 'JAX';"
cursor.execute(delete_string)
conn.commit()
