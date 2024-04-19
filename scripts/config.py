import os
from configparser import ConfigParser

def load_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    print(f"sections {parser.sections()}")
    parser.read(filename)
    print(f"sections {parser.sections()}")
    config = {}

    if parser.has_section(section):
        params = parser.items(section)
        for key,value in params:
            config[key] = value
    else:
        raise Exception(f"Section {section} not found in the {filename} file")

    return config

if __name__ == '__main__':
    config = load_config()
    print(config)

# FROM https://www.postgresqltutorial.com/postgresql-python/connect/