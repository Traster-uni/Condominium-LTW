import os
import json
import psycopg2
from configparser import ConfigParser

# CONFIGURATION LOADER
def load_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    fname_abs = os.path.dirname(os.path.abspath(__file__))
    parser.read(os.path.join(fname_abs, filename))
    
    config = dict()
    if parser.has_section(section):
        params = parser.items(section)
        for key,value in params:
            if key == "port":
                config[key] = int(value)
            else:
                config[key] = value
    else:
        raise Exception(f"Section {section} not found in the {filename} file")

    return config


def connect(config):
    print(f"connect ---> {config}")
    try:
        # connecting to the PostgreSQL server
        with psycopg2.connect(**config) as conn:
            print(f"Connected to the PostgreSQL server at {config['host']}:{config['port']}")
            return conn
    except (psycopg2.DatabaseError, Exception) as err:
        print(err)
    return


def load_data(fname="data.json"):
    data = dict()
    fname_abs = os.path.dirname(os.path.abspath(__file__))

    with open(os.path.join(fname_abs, fname)) as f:
        data = json.load(f)   
    return data

def insert_data(data:dict, connection:psycopg2.connect):
    cur = connection.cursor()

    for table_name in data:
        for instance in table_name:
            cur.execute(f"INSERT {table_name}")

if __name__ == '__main__':
    config = load_config("database.ini")
    conn = connect(config)
    d = load_data("default_schema_values")
    insert_data(d, conn)

# from https://www.postgresqltutorial.com/postgresql-python/connect/
