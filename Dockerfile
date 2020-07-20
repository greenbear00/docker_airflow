FROM centos:7.6.1810
LABEL MAINTANER="greenbear.woo@gmail.com"

RUN whoami
# USER root

RUN echo 'root:root' | chpasswd

# timezone 설정
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN date


# 다만, CentOS 7에서는 아래 ius가 안먹힘
# RedHat계열의 Linux와 CentOS에 안정적이고 퀄리티 높은 RPM을 제공해주는 것이 주 목적
# RUN yum install https://centos7.iuscommunity.org/ius-release.rpm
RUN yum update -y
RUN yum install -y sudo
RUN yum install -y wget
RUN yum groupinstall -y development
RUN yum install -y which
# 아래는 airflow를 위한 dependencies가 있는 패키지
RUN yum install -y gcc gcc-c++ postgresql-devel ibffi-devel
RUN yum install -y zlib-devel
RUN yum install -y vim
RUN yum install -y telnet
RUN yum install -y llvm
RUN yum install -y openssl-devel
RUN yum install -y sqlite-devel
RUN yum install -y openssh-server
# RUN yum install -y python3-devel
# RUN yum install -y python-devel mysql-devel

RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22 


# python & pip install
RUN yum install --assumeyes python3-pip
RUN yum install -y python36-devel
RUN export PIP_DEFAULT_TIMEOUT=100
# RUN unlink /bin/python
# RUN ln -s /bin/python3.6 /bin/python
RUN ln -s /bin/pip3 /bin/pip
RUN echo "alias python='/usr/bin/python3'" >> /home/.bashrc
RUN source /home/.bashrc
RUN python3 --version
RUN python3 -m pip install --upgrade pip

# python관련 requirements.txt 설치

WORKDIR /usr/local/airflow/
COPY ./config/requirements.txt /usr/local/airflow/requirements.txt
RUN pip3 install -r requirements.txt
RUN pip3 list
# RUN pip3 install apache-airflow==1.10.10 \
#  --constraint https://raw.githubusercontent.com/apache/airflow/1.10.10/requirements/requirements-python3.6.txt
RUN find / -name airflow.cfg


RUN useradd airflow

RUN pwd
RUN ls -l
RUN mkdir dags
RUN mkdir logs
RUN mkdir plugins
COPY ./config/airflow.cfg /usr/local/airflow/airflow_backup.cfg
COPY ./config/simple_dag.py /usr/local/airflow/dags/simple_dag.py
COPY ./config/app.py /usr/local/lib/python3.6/site-packages/airflow/www_rbac/app.py

COPY ./config/wait_it_psql.sh /home/airflow/wait_it_psql.sh
COPY ./config/wait_it_psql_and_create_user.sh /home/airflow/wait_it_psql_and_create_user.sh
RUN chmod 755 /home/airflow/*.sh

RUN cp /usr/local/airflow/airflow_backup.cfg /usr/local/airflow/airflow.cfg
RUN chown -R airflow:airflow /home/airflow
RUN chmod +x /home/airflow/*.sh
RUN ls -l /home/airflow/
# RUN cp simple_dag.py dags/simple_dag.py
# RUN ls -l dags
# RUN cp simple_dag.py ./dags/simple_dag.py
# RUN ls -l dags
# RUN chmod +x *.sh
RUN chown -R airflow:airflow /usr/local/airflow
RUN ls -l

ENV SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://postgres:postgres@postgres:5432/airflow
ENV SQLALCHEMY_BINDS=postgresql+psycopg2://postgres:postgres@postgres:5432/airflow

# EXPOSE 8080
EXPOSE 5555
EXPOSE 8793
EXPOSE 6379
EXPOSE 5432


USER airflow
RUN LC_ALL=en_US.utf-8
RUN LANG=en-US.utf-8
ENV AIRFLOW_HOME=/usr/local/airflow
WORKDIR /usr/local/airflow

# RUN echo $AIRFLOW_DATABASE_HOST
RUN pwd
RUN ls -l






# airflow를 설치 후, initdb를 한 다음에 admin계정 생성 필요
# airflow create_user -u admin -p admin -r Admin -e greenbear.woo@gmail.com -f sujeong -l woo