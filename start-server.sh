#!/bin/bash
echo "starting web server to listen to github webhooks"

./start-server.sh &
echo $! > server.pid
