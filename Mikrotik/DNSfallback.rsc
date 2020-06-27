#
# DNSfallback.rsc - if internal DNS down swap to public one.
#
# https://wiki.mikrotik.com/wiki/Manual:IP/DNS

# _PREREQUIREMENTS:

/tool fetch url="https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"

/certificate import file-name=DigiCertGlobalRootCA.crt.pem

========

# _VARS:
<IP>

========
/ip dns set allow-remote-requests=yes servers=<IP>

/tool netwatch
add comment=alterDNS down-script="/log warning \"internal DNS down. fallback to pub\"\r\
    \n/ip dns cache flush\r\
    \n/ip dns set servers=\"1.1.1.1\"\r\
    \n/ip dns set use-doh-server=https://cloudflare-dns.com/dns-query verify-doh-cert=yes" host=<IP> \
    interval=1s timeout=500ms up-script="/log warning \"internal DNS UP. Switching to internal\"\r\
    \n/ip dns cache flush\r\
    \n/ip dns set servers=\"<IP>\"\r\
    \n/ip dns set use-doh-server=\"\" verify-doh-cert=no"


========
