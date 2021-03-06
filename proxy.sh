#!/bin/sh

HOSTNAME=`hostname`

if [ "$PROXY_PROXY" != "1" ]
then
  PROXY_IMG=`docker inspect $HOSTNAME | jq .[0].Image | tr -d '"' | awk -F: '{print $2}'`
  
  PROXY_SOCKS=""
  for port in $PROXY_PORTS
  do
    echo "Forwarding port to /var/run/proxy-$HOSTNAME-$port.sock $PROXY_DST"
    #rm -f backfifo$port
    #mkfifo backfifo$port
    rm -f /var/run/proxy-$HOSTNAME-$port.sock
    #nc -klU /var/run/proxy-$HOSTNAME-$port.sock | nc $PROXY_DST $port >backfifo$port &
    socat UNIX-LISTEN:/var/run/proxy-$HOSTNAME-$port.sock,fork,su=nobody TCP:$PROXY_DST:$port &

    PROXY_SOCKS=$PROXY_SOCKS"-v /var/run/proxy-$HOSTNAME-$port.sock:/var/run/proxy-$HOSTNAME-$port.sock "
  done
  
  echo "RUNNING SECOND PROXY" 
  exec docker run --rm --name docker-proxy-$HOSTNAME -it $PROXY_SOCKS -e PROXY_PORTS="$PROXY_PORTS" -e PROXY_PROXY="1" -e PROXY_HOST="$HOSTNAME" -e PROXY_CMD="$PROXY_CMD" $PROXY_OPTS $PROXY_IMG sh -c /proxy.sh
else
  for port in $PROXY_PORTS
  do
    echo "Forwarding port $port to /var/run/proxy-$PROXY_HOST-$port.sock"
    #rm -f backfifo$port
    #mkfifo backfifo$port
    #nc -kl $port <backfifo$port | nc -U /var/run/proxy-$PROXY_HOST-$port.sock >backfifo$port &
    socat TCP-LISTEN:$port,fork,reuseaddr UNIX-CONNECT:/var/run/proxy-$PROXY_HOST-$port.sock &
  done 
  echo "RUNNING COMMAND"
  exec $PROXY_CMD
fi


