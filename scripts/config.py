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
    with open(fname) as f:
        data = json.load(f)
        print(type(data))
        for rows in data:
            print(rows)
    return data

if __name__ == '__main__':
    config = load_config()



# FROM https://www.postgresqltutorial.com/postgresql-python/connect/