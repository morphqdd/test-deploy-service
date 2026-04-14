#!/bin/bash
set -e

SERVICE=test-deploy-service
BINARY=/usr/local/bin/$SERVICE
PIDFILE=/var/run/$SERVICE.pid
LOGFILE=/var/log/$SERVICE.log
PORT=${PORT:-8080}

echo "==> building..."
go build -o $BINARY .

echo "==> stopping old instance..."
if [ -f $PIDFILE ]; then
  kill $(cat $PIDFILE) 2>/dev/null || true
  rm -f $PIDFILE
fi
pkill -f $SERVICE 2>/dev/null || true
sleep 1

echo "==> starting..."
PORT=$PORT ECHO_TEXT="hello from syncswarm" nohup $BINARY >> $LOGFILE 2>&1 &
echo $! > $PIDFILE

sleep 1
if kill -0 $(cat $PIDFILE) 2>/dev/null; then
  echo "==> running (pid $(cat $PIDFILE))"
else
  echo "error: failed to start"
  exit 1
fi
