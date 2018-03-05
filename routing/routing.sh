#!/bin/bash


LAN=br0

WAN="ppp1 ppp2"

START() {
	for w in $WAN; do
		bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
		#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
		iptables -A POSTROUTING -t nat -o $w -j MASQUERADE
		iptables -A FORWARD -i $w -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
		iptables -A FORWARD -i $LAN -o $w -j ACCEPT
		iptables -t nat -L -vn
		iptables -L -nv
	done
    sudo ip route replace default scope global \
        nexthop dev ppp1 weight 1 \
        nexthop dev ppp2 weight 1
}

STOP() {
	for w in $WAN; do
		bash -c 'echo 0 > /proc/sys/net/ipv4/ip_forward'
		#iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
		iptables -D POSTROUTING -t nat -o $w -j MASQUERADE
		iptables -D FORWARD -i $w -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
		iptables -D FORWARD -i $LAN -o $w -j ACCEPT
		iptables -t nat -L -vn
		iptables -L -nv
	done
    sudo ip route replace default dev ppp1 scope link
}

case "$1" in
  start)
    START
    ;;

  stop)
    STOP
    ;;

  *)
    echo $"Usage: $0 {\"start\"}"
    exit 1

esac
