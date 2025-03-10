#!/bin/sh

set -e

case "$1" in
    start|stop)
        cmd=$1
        ;;
    *)
        echo "usage: $0 {start|stop}"
        exit 1
esac
#echo "cmd: $cmd"

dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#echo "dir: $dir"

if [ -f "${dir}/aesdsocket" ]; then
    # echo "Using aesdsocket from ${dir}"
    aesdsocket="${dir}/aesdsocket"
elif [ -f /usr/bin/aesdsocket ]; then
    # echo "Using /usr/bin/aesdsocket"
    aesdsocket=/usr/bin/aesdsocket
else
    echo "Couldn't find aesdsocket"
    exit 1
fi
#echo "aesdsocket: $aesdsocket"

case "$cmd" in
    start)
        echo "Starting aesdsocket daemon..."
        start-stop-daemon -v --start --exec ${aesdsocket} -- -d
        # Alternatively:
        # start-stop-daemon -v --start --pidfile /var/tmp/aesdsocketd.pid --startas ${aesd} -- -d
        ;;
    stop)
        echo "Stopping aesdsocket daemon..."
        start-stop-daemon -v --stop --exec ${aesdsocket}
        # Alternatively:
        # start-stop-daemon -v --stop --pidfile /var/tmp/aesdsocketd.pid
        ;;
esac