#!/bin/bash
#
# This file is needed to simplify running more than on server on the same machine.
# 
# We need to tell the master server which port docker is listening to,
# and not which port the game server is listening to.
# Game server always listens to the same port, but only one container can expose the same port on a host.
# /forceip is used to change what IP:PORT the game server tells to the master server.
# Usage `-e PORT=2351 -p 2351:2350 -p 2351:2350/udp` - Make sure PORT equals the port exposed on the host machine.
#                ^^^^    ^^^^         ^^^^---<---<-- equal
# 
# There is a bug in ManiaPlanetServer so that /forceip doesn't work unless /dedicated_cfg is valid.
#   This is solved by adding a /dedicated_cfg at the end of the command.
#   If a /dedicated_cfg has already been set in the cmd, this fake cfg will be ignored.
#   If you choose to do so, make sure you set `xmlrpc_allowremote` to `True` to be able to connect to port 5000.
# 
# There is another bug in ManiaPlanetServer so that when not run in a tty,
# all its output is buffered until it's closed.
#   This is solved by tailing the log.
# 


# Get public IP to be able to /forceip.
IP=`wget -qO- http://ip.alf.nu/`

# Run the server and pass all arguments to it as settings some
./ManiaPlanetServer $@ \
	/nodaemon \
  /forceip=$IP:${PORT-2350} \
  /dedicated_cfg=default.xml \
  >/dev/null &

# The rest of this file is a workaround for the non-tty bug...

# Remember PID of the server
serverPID=$!

# Kill server if we get SIGTERM (docker stop <container>)
trap "kill $serverPID" SIGTERM

# Sleep for 1s to make sure the server has created the log file
sleep 1

# Tail the log file, and remember pid (to kill later)
tail -fn1000 Logs/ConsoleLog.$serverPID.txt & tailPID=$!

# Wait for server to exit
wait $serverPID

# Then kill tail
kill $tailPID


# TODO

# docker run \
#   -e PORT=2355 -p2355 -p2355/udp
# docker run -e PORT=2355 -p2355:2350 -p2355:2350/udp
