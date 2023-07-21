#!/usr/bin/env sh

for arg in $@
do
    if [ "$arg" = "shell" ]
    then
        exec bash
    elif [ "$arg" = "background" ]
    then
        exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
    fi
done
