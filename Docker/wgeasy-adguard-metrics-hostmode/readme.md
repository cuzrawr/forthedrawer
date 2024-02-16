VPN-WG-Adguard-Metrics

----

Description:
Dockerized small && user-friendly VPN interface based on wg-easy project:

, coupled with AdGuard DNS for AD filtering + privacy
, and little VNStat for network metrics.

Perfect for small home size VPN deploy.

Using host mode networking.

#########################
# Web access:
#
# http://10.20.30.1:3000  - Adguard admin panel & first setup required.
# http://10.20.30.1:51821 - Wireguard admin panel.
# http://10.20.30.1:8685  - traffic metrics.
#
# Adjust and check all confs !!!
# This entire VPN configs writed for 512MiB system!
#########################

----


.service files from systemd should be placed

like this

/etc/systemd/system/docker_wireguard_dns.service


enabled & activated

you can chose to enable or no metrics, but wg+dns harcoded.

----

Inside /etc_test
some usefull examples of confs for deploying

