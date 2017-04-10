FROM python:2.7
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential libxml2-dev libxslt-dev git \
    python-dev python-pip virtualenv \
    npm nodejs nodejs-legacy \
    pandoc \
    texlive \
    apache2 libapache2-mod-wsgi

RUN npm -g install bower

RUN git clone https://github.com/rdmorganiser/rdmo

WORKDIR rdmo

RUN pip install --upgrade pip
RUN pip install -r requirements/base.txt
RUN pip install -r requirements/postgres.txt
RUN pip install -r requirements/mysql.txt

ADD local.py rdmo/settings/local.py
ADD apache.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir components_root static_root media_root static

RUN python manage.py bower_install --allow-root
RUN python manage.py collectstatic --no-input

RUN chown -R www-data:www-data static_root media_root

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV APACHE_LOCK_DIR=/var/lock/apache2

EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
