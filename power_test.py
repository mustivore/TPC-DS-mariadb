import os
import time
import mysql.connector
import configparser

datadir = "C:/tpcds-kit/tools/generated_query"


def msec_to_sec(msecs):
    secs = msecs // 1000
    msecs -= secs * 1000
    return secs + msecs / 1000.0


def msecs():
    return int(time.time()) * 1000


if __name__ == "__main__":
    total_secs = 0

    config = configparser.ConfigParser()
    config.read('config.ini')

    db_host = config['Database']['host']
    db_user = config['Database']['username']
    db_name = config['Database']['database']
    db_port = int(config['Database']['port'])

    for file in os.listdir(datadir):
        if file.endswith(".sql"):
            try:
                connection = mysql.connector.connect(
                    host=db_host,
                    user=db_user,
                    database=db_name,
                    port=db_port
                )
                cursor = connection.cursor()
                sql_file_path = os.path.join(datadir, file)
                print("Executing script", file)

                with open(sql_file_path, "r") as sql_file:
                    sql_commands = sql_file.read().strip().split(';')
                    start = msecs()
                    for sql_command in sql_commands:
                        cursor.execute(sql_command)
                    duration = msecs() - start
                    cursor.fetchall()

                secs = msec_to_sec(duration)
                print("{:>23}: \t{:>16} secs".format(file, secs))
                total_secs += secs
            except Exception as e:
                print("An error occurred:", str(e))

            finally:
                cursor.close()
                connection.close()

    print("Total duration: ", total_secs)
