#!/bin/bash

# Ensure that worker entrypoint does not also run nginx processes
if [ $CONTAINER_ROLE != 'web' ]
then
  echo "[run] bypassing web startup"
  exit 0
fi

# Enable nginx as an S6-supervised service
if [ "$S6_OVERRIDE" == 1 ]
then
  echo '[run] avoiding S6 supervision'
else
  if [ -d /etc/services.d/nginx ]
  then
    echo '[run] web server already enabled'
  else
    echo '[run] enabling web server'
    ln -s /etc/services-available/nginx /etc/services.d/nginx
  fi
fi


if [[ $SERVER_APP_NAME ]]
then
  echo "[run] adding app name (${SERVER_APP_NAME}) to log format"
  sed -i "s/NGINX_SERVER/${SERVER_APP_NAME}/" $CONF_NGINX_SERVER
else
  echo "[run] missing \$SERVER_APP_NAME to add to log lines, please add environment variable"
fi

if [[ $SERVER_SENDFILE ]]
then
  echo "[run] server sendfile status is ${SERVER_SENDFILE}"
  sed -i "s/sendfile .*;/sendfile ${SERVER_SENDFILE};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_MAX_BODY_SIZE ]]
then
  echo "[run] server client max body is ${SERVER_MAX_BODY_SIZE}"
  sed -i "s/client_max_body_size .*;/client_max_body_size ${SERVER_MAX_BODY_SIZE};/" $CONF_NGINX_SITE
fi

if [[ $SERVER_INDEX ]]
then
  echo "[run] server index is ${SERVER_INDEX}"
  sed -i "s/index .*;/index ${SERVER_INDEX};/" $CONF_NGINX_SITE
fi

if [[ $SERVER_GZIP_OPTIONS ]]
then
  echo "[run] enabling gzip"
    # Uncomments all gzip handling options
  sed -i "s/\#gzip/gzip/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_KEEPALIVE ]]
then
  echo "[run] setting keepalive ${SERVER_KEEPALIVE}"
  sed -i "s/\keepalive_timeout .*;/keepalive_timeout ${SERVER_KEEPALIVE};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_WORKER_PROCESSES ]]
then
  echo "[run] setting worker processes ${SERVER_WORKER_PROCESSES}"
  sed -i "s/\worker_processes .*;/worker_processes ${SERVER_WORKER_PROCESSES};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_WORKER_CONNECTIONS ]]
then
  echo "[run] setting worker connection limit ${SERVER_WORKER_CONNECTIONS}"
  sed -i "s/\worker_connections .*;/worker_connections ${SERVER_WORKER_CONNECTIONS};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_LOG_MINIMAL ]]
then
  echo "[run] enabling minimal logging"
  sed -i "s/access_log \/dev\/stdout .*;/access_log \/dev\/stdout minimal;/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_LARGE_CLIENT_HEADER_BUFFERS ]]
then
  echo "[run] setting large_client_header_buffers to ${SERVER_LARGE_CLIENT_HEADER_BUFFERS}"
  sed -i "s/large_client_header_buffers .*;/large_client_header_buffers ${SERVER_LARGE_CLIENT_HEADER_BUFFERS};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_CLIENT_HEADER_BUFFER_SIZE ]]
then
  echo "[run] setting client_header_buffer_size to ${SERVER_CLIENT_HEADER_BUFFER_SIZE}"
  sed -i "s/client_header_buffer_size .*;/client_header_buffer_size ${SERVER_CLIENT_HEADER_BUFFER_SIZE};/" $CONF_NGINX_SERVER
fi

if [[ $SERVER_CLIENT_BODY_BUFFER_SIZE ]]
then
  echo "[run] setting client_body_buffer_size to ${SERVER_CLIENT_BODY_BUFFER_SIZE}"
  sed -i "s/client_body_buffer_size .*;/client_body_buffer_size ${SERVER_CLIENT_BODY_BUFFER_SIZE};/" $CONF_NGINX_SERVER
fi

