import psycopg2
import os
from config import load_config

def connect(config):
    try:
        # connecting to the PostgreSQL server
        with psycopg2.connect(**config) as conn:
            print(f"Connected to the PostgreSQL server at {config['host']}:{config['port']}")
            return conn
    except (psycopg2.DatabaseError, Exception) as err:
        print(err)

if __name__ == '__main__':
    config = load_config(os.getcwd()+"\\database.ini")
    connect(config)

# from https://www.postgresqltutorial.com/postgresql-python/connect/
