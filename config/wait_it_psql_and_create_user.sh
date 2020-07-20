#!/bin/sh

echo "hello"

host="$1"

# 명령어 확인
echo "argument 0 1 2 3 host => '$0' '$1' '$2' '$3' '$host"
shift
echo "the remainder argument is '$@' and previous argument is '$host'"
cmd=$@

# postgres 컨테이너 띄워지기까지 대기
until PGPASSWORD=postgres psql -h "$host" -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done


pwd
ls -l
echo "############ Run airflow initdb (postgres is running) #############"
$cmd
echo "airflow initdb done"

echo "############ Is airflow.cfg ? (check executor, sql_alchemy_conn, webserver rabc) ########### "
# sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
# executor = LocalExecutor
# rabc = True
ls -l
echo ">> cat airflow.cfg"
cat airflow.cfg | grep "executor"
cat airflow.cfg | grep "sql_alchemy_conn"
cat airflow.cfg | grep "rabc"



echo "############ Run webserver user #############"
# PGPASSWORD=airflow psql -h "$host" -U "postgres" -c 'grant all privileges on all tables in schema public to postgres'
echo "create admin user for WEB_UI"
# echo "airflow -help"
echo "$SQLALCHEMY_DATABASE_URI"
echo "$SQLALCHEMY_BINDS"
airflow create_user -u admin -p admin -r Admin -e greenbear.woo@gmail.com -f sujeong -l woo

## echo "cp simple_dag to /usr/local/airflow/dags/simple_dag.py"
## cp simple_dag.py dags/simple_dag_copy.py

echo "############ Check dags #############"
echo "/usr/local/airflow/dags"
ls -l dags