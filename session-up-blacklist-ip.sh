#!/bin/bash
INTERFACE="$3"
MTU="$4"
IP="$5"
UUID="$8"

log_message() {
    message="$1"
    logger -p 6 -t "Tunneldigger" "$message"
##    echo "$message" | systemd-cat -p info -t "Tunneldigger"
    echo "$1" 1>&2
}

if /bin/grep -q "^$UUID$" /etc/tunneldigger/ggrz/blacklist.txt; then
        OLDIP=$(/sbin/iptables -L -n | /bin/grep -- "/* $UUID" | awk '{print $4}')
        if test -z "$OLDIP"; then
                log_message "New client with UUID=$UUID is blacklisted, blocking ip address $IP"
                /sbin/iptables -A INPUT -s $IP -j DROP -m comment --comment "$UUID"
        else
                # hier könnte man noch abfragen, ob $IP gleich $OLDIP ist
                # ist aber Quatsch, weil der Client in diesem Fall ja schon geblockt wird
                # und gar nicht bis hier durchkommt
                log_message "New client with UUID=$UUID is blacklisted, blocking new ip address $IP (previously used $OLDIP removed)"
                /sbin/iptables -D INPUT -s $OLDIP -j DROP -m comment --comment "$UUID"
                /sbin/iptables -A INPUT -s $IP -j DROP -m comment --comment "$UUID"
        fi
else
        log_message "New client with UUID=$UUID connected, adding to batman interface"
        /bin/ip link set dev $INTERFACE up mtu $MTU
        ##/sbin/brctl addif ggrzL2TP $INTERFACE
        /usr/sbin/batctl -m ggrzBAT if add $INTERFACE
fi
