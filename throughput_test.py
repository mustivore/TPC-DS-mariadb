import configparser
import os
import time

import mysql.connector
from concurrent.futures import ThreadPoolExecutor
import random

datadir = "C:/tpcds-kit/tools/generated_query"


def msec_to_sec(msecs):
    secs = msecs // 1000
    msecs -= secs * 1000
    return secs + msecs / 1000


def get_time():
    return int(time.time()) * 1000


def run_queries(queries):
    config = configparser.ConfigParser()
    config.read('config.ini')

    db_host = config['Database']['host']
    db_user = config['Database']['username']
    db_name = config['Database']['database']
    db_port = int(config['Database']['port'])

    for query in queries:
        connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            database=db_name,
            port=db_port
        )
        print(query)
        sql_file_path = os.path.join(datadir, query)
        cursor = connection.cursor()
        with open(sql_file_path, "r") as sql_file:
            sql_commands = sql_file.read().strip().split(';')
            for sql_command in sql_commands:
                cursor.execute(sql_command)
                cursor.fetchall()
        cursor.close()
        connection.close()


if __name__ == "__main__":

    query_files = [f for f in os.listdir(datadir) if f.endswith(".sql")]
    nb_client = 4

    start = get_time()
    with ThreadPoolExecutor(max_workers=nb_client) as executor:
        clients_query_files = [query_files.copy() for _ in range(nb_client)]
        for queries in clients_query_files:
            random.shuffle(queries)  # Shuffle the order for each client
            executor.submit(run_queries, queries)
    duration = get_time() - start

    print("Total duration:", msec_to_sec(duration))
