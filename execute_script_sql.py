import mysql.connector
import configparser
import sys
import time



def msec_to_sec(msecs):
    secs = msecs // 1000
    msecs -= secs * 1000
    return secs + msecs / 1000.0


def msecs():
    return int(time.time()) * 1000


if __name__ == "__main__":
    if len(sys.argv) <= 1 or not sys.argv[1].endswith(".sql"):
        print("Please provide a SQL file.")
        exit(1)

    config = configparser.ConfigParser()
    config.read('config.ini')

    db_host = config['Database']['host']
    db_user = config['Database']['username']
    db_name = config['Database']['database']
    db_port = int(config['Database']['port'])

    try:
        connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            database=db_name,
            port=db_port
        )

        cursor = connection.cursor()

        with open(sys.argv[1]) as sql_file:
            start = msecs()
            for statement in sql_file.read().split(';'):
                statement = statement.strip()
                cursor.execute(statement)
            connection.commit()
            duration = msecs() - start
            secs = msec_to_sec(duration)
            print("Script executed succesfully.")
            print("Total duration ", secs, "secs")

    except Exception as e:
        print("Something went wrong", e)
    finally:
        cursor.close()
        connection.close()
