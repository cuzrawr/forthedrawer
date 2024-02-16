# VPN-WG-Adguard-Metrics

## Description
VPN-WG-Adguard-Metrics is a Dockerized, small, and user-friendly VPN interface based on the wg-easy project. It is coupled with AdGuard DNS for ad filtering and privacy enhancement, along with VNStat for network metrics. This solution is perfect for deploying a small home-size VPN with ease.

This setup utilizes host mode networking for seamless integration.

## Features
- Dockerized VPN interface based on wg-easy.
- Integration with AdGuard DNS for ad filtering and privacy enhancement.
- Incorporates VNStat for network traffic metrics.
- Designed for small-scale home VPN deployments.
- Simplified setup and usage.

## Access Points
- [Adguard Admin Panel & Setup](http://10.20.30.1:3000)
- [Wireguard Admin Panel](http://10.20.30.1:51821)
- [Traffic Metrics](http://10.20.30.1:8685)

**Note:** Make sure to adjust and review all configurations before deployment. The entire VPN configurations are optimized for systems with 512MiB memory.

## Installation
1. Copy the `.service` files from systemd to `/etc/systemd/system/` as follows:
    ```
    /etc/systemd/system/docker_wireguard_dns.service
    ```
2. Ensure the services are enabled and activated.

## Configuration Examples
Inside the `/etc_test` directory, you'll find useful examples of configurations for deployment.

## Note
You have the option to enable or disable metrics, but Wireguard and DNS configurations are hardcoded.

