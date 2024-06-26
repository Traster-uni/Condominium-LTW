import os
import json
import psycopg2
import re
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


def connect(config, s_name = "null"):
    print(f"connect ---> {config}")
    try:
        # connecting to the PostgreSQL server
        with psycopg2.connect(**config) as conn:
            print(f"Connected to the PostgreSQL server at {config['host']}:{config['port']}")
            d = load_data("default_schema_values.json")
            insert_data(d, conn, s_name)
    except (psycopg2.DatabaseError, Exception) as err:
        print(err)
    return


def load_data(fname="data.json"):
    data = dict()
    fname_abs = os.path.dirname(os.path.abspath(__file__))

    with open(os.path.join(fname_abs, fname)) as f:
        data = json.load(f)
    return data

def insert_data(data, connection, schema_name="null"):
    cur = connection.cursor()
    if schema_name not in data.keys():
        print("no matching key for given schema name")
        return
    if schema_name == "null":
        for table_name in data:
            keys_list = table_name[0].keys()
            for instance in data[table_name]:
                values_list = instance.values()
                query_str = "INSERT INTO " + table_name + "("
                for i,k in enumerate(keys_list):
                    query_str += k
                    if i < len(values_list)-1:
                        query_str += ", "
                query_str += ")\n\tVALUES ("
                for i,v in enumerate(values_list):
                    if type(v) is int:
                        query_str += str(v)
                    else:
                        query_str += "'" + v + "'"
                    if i < len(values_list)-1:
                        query_str += ", "
                query_str += ");"
                print(query_str)
                cur.execute(query_str)
            
            for k in keys_list:
                id_field = str(re.search("^.*_id$", k))
                break

            if id_field in keys_list:
                cur.execute(f"SELECT setval(pg_get_serial_sequence('{table_name}', '{id_field}'), (SELECT MAX({id_field}) FROM {table_name}) + 1);")
        cur.close()
    else:
        keys_list = data[schema_name][0].keys()
        for instance in data[schema_name]:
            values_list = instance.values()
            query_str = "INSERT INTO " + schema_name + "("
            for i,k in enumerate(keys_list):
                query_str += k
                if i < len(values_list)-1:
                    query_str += ", "
            query_str += ")\n\tVALUES ("
            for i,v in enumerate(values_list):
                if type(v) is int:
                    query_str += str(v)
                else:
                    query_str += "'" + v + "'"
                if i < len(values_list)-1:
                    query_str += ", "
            query_str += ");"
            print(query_str)
            cur.execute(query_str)
        
        table_name = schema_name
        for k in keys_list:
            id_field = str(re.search("^.*_id$", k))
            break

        if id_field in keys_list:
            cur.execute(f"SELECT setval(pg_get_serial_sequence('{table_name}', '{id_field}'), (SELECT MAX({id_field}) FROM {table_name}) + 1);")
        cur.close()
    return
    
if __name__ == '__main__':
    config = load_config("database.ini")
    conn = connect(config)

# from https://www.postgresqltutorial.com/postgresql-python/connect/
