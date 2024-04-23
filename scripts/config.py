import os
import json
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

def load_data(fname="data.json"):
    data = dict()
    fname_abs = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(fname_abs, fname)) as f:
        data = json.load(f)
        for rows in data:
            print(rows)
    print(data)
    return data

if __name__ == '__main__':
    config = load_config()
    load_data("default_schema_values.json")



# FROM https://www.postgresqltutorial.com/postgresql-python/connect/