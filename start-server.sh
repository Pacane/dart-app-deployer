#!/bin/bash
POKER_PLANNING="../pokerplanning"
SERVER_PATH="../pokerplanning/PokerPlanningServer"
CLIENT_PATH="../pokerplanning/PokerPlanningClient"

echo "killing existing web server"
SERVER_PID=$(head -n 1 server.pid)
kill -9 $SERVER_PID

echo "killing existing client"
CLIENT_PID=$(head -n 1 client.pid)
kill -9 $CLIENT_PID

echo "Resetting master branch"
git --git-dir="$POKER_PLANNING/.git" reset --hard pacane/master
git --git-dir="$POKER_PLANNING/.git" pull pacane master

echo "starting server"
(cd $SERVER_PATH && dart -c main.dart) &
echo $! > server.pid

echo "starting client"
(cd $CLIENT_PATH && pub serve --port=3000 --hostname=stacktrace.ca --mode=release) &
echo $(ps aux | awk '/--port=3000/ {print $2;}' | head -n1) > client.pid
