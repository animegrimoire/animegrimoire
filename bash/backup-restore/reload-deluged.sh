#!/bin/bash
# enable local routing
sudo sysctl -w net.ipv4.conf.tun0.route_localnet=1

# make sure ports are allowed for deluged use
sudo firewall-cmd --zone=public --add-port=8090/tcp
sudo firewall-cmd --zone=public --add-port=49200-49210/udp
sudo firewall-cmd --zone=public --add-port=49200-49210/tcp
sudo firewall-cmd --zone=public --add-service=deluged
sudo firewall-cmd --zone=external --add-masquerade
sudo firewall-cmd --zone=external --add-forward-port=port=8090:proto=tcp:toport=58846:toaddr=127.0.0.1
sudo iptables -A PREROUTING -t nat -i tun0 -p tcp --dport 8090 -j DNAT --to 127.0.0.1:58846
sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 8090 -j ACCEPT
sudo firewall-cmd --reload

# restart deluged and openvpn-client
sudo systemctl restart openvpn-client@encodingbox.service
sudo systemctl restart deluged
sudo systemctl status openvpn-client@encodingbox.service
sudo systemctl status deluged
