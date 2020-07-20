#!/bin/sh

echo "hello"

# echo "{'$0'} is $0"
# echo "'$1' is $1"
# echo "'$2' is $2"
# echo "'$3' is $3"
# echo "'$#' is $#"
# echo "'$@' is $@"


# origin_arg=$*
host="$1"
# shift
# # cmd="$@"
# last_arg=$*


echo "argument 0 1 2 3 host => '$0' '$1' '$2' '$3' '$host" 
# shift는 arguments의 인자를 하나씩 지우는 역할임
shift
echo "the remainder argument is '$@' and previous argument is '$host'"
cmd=$@

# psql 명령어 중 \l은 database instance 보여주기이고, 
# -h로 원격접속시에는 password를 입력해야 하는데, 아래와 같이 psql에서 사용하는 PGPASSWORD를 지정해서 connection 확인 하면 됨
until PGPASSWORD=postgres psql -h "$host" -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done


ls -l

>&2 echo "Postgres is up"
for i in {1..15};do
  >&2 echo "...wait until airflow initdb and create user $i"
  sleep 1
done

ls -l dags

# echo "do command>> $cmd > $2.log 2>&1"
# $cmd > $2.log 2>&1
echo "do command>> $cmd"
nohup $cmd &

echo "do command>> airflow scheduler"
nohup airflow scheduler 
