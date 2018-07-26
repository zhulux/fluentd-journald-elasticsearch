#!/usr/bin/dumb-init /bin/bash

uid=${FLUENT_UID:-1000}

# check if a old fluent user exists and delete it
cat /etc/conf.d/passwd | grep fluent
if [ $? -eq 0 ]; then
    deluser fluent
fi

# (re)add the fluent user with $FLUENT_UID
useradd -u ${uid} -o -c "" -m fluent
export HOME=/home/fluent

# chown home and data folder
chown -R fluent /home/fluent
chown -R fluent /fluentd

set -e
# Seting dynamic variable
if [[ -z ${FLUENT_ELASTICSEARCH_USER} ]] ; then
    sed -i  '/FLUENT_ELASTICSEARCH_USER/d' /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
else
    sed -i "s/FLUENT_ELASTICSEARCH_USER/$FLUENT_ELASTICSEARCH_USER/g" /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
fi

if [[ -z ${FLUENT_ELASTICSEARCH_PASSWORD} ]] ; then
    sed -i  '/FLUENT_ELASTICSEARCH_PASSWORD/d' /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
else
    sed -i "s/FLUENT_ELASTICSEARCH_PASSWORD/$FLUENT_ELASTICSEARCH_PASSWORD/g" /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
fi

if [[ -n ${FLUENT_ELASTICSEARCH_HOST} ]]; then
    sed -i "s/FLUENT_ELASTICSEARCH_HOST/$FLUENT_ELASTICSEARCH_HOST/g" /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
fi

if [[ -n ${FLUENT_ELASTICSEARCH_PORT} ]]; then
    sed -i "s/FLUENT_ELASTICSEARCH_PORT/$FLUENT_ELASTICSEARCH_PORT/g" /fluentd/etc/conf.d/${FLUENTD_OUTPUT}
fi

exec gosu root "$@"
