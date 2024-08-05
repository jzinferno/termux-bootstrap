#!/system/bin/sh

if [ ! -f "$(/system/bin/realpath $0)".lock ]; then
    /system/bin/ln -s termux-bootstrap-second-stage.sh "$(/system/bin/realpath $0)".lock
fi
