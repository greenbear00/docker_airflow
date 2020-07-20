apache-airflow==1.10.10
-------------



### LocalExecutor with postgres

1. airflow.cfg에서 수정사항
>sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
>executor = LocalExecutor
>rabc = True (이것과 연관되서 /usr/local/lib/python3.6/site-packages/airflow/www_rbac/app.py 파일에 아래 내용 추가)
>>app.config['SQLALCHEMY_DATABASE_URI'] = conf.get('core', 'SQL_ALCHEMY_CONN')
>>...
>>csrf.init_app(app)

2. postgres 컨테이너에 대해서 host네임을 찾기 위해서 volumes를 services와 동일 레벨에서 지정해줌
참고로, links는 요즘 안쓰는 추세임
>version: "3"
>>services:
>>>postgres:
>>>>....
>>>initdb:
>>>>....
>>>airflow_webserver:
>>>>....
>>volumes:
>>>postgres:
>>>airflow:


3. scripts
- wait_it_psql_and_create_user.sh
check that Is running psql? and airflow initdb and create user for webserver.
- wait_it_psql.sh
check that Is running psql? and wait 15sec because airflow initdb.
and then run airflow webserver, airflow scheduler 


4. how to run?
>docker-compose up --build

.