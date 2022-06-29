#
# gemini server  shavit (golang): https://git.sr.ht/~yotam/shavit '
#
#
# WARNING: HARDERING DISABLES ALL SHELL ACCESS INSIDE CONTAINER !!!
#
#
#

#
# Builder ( STAGE 1 )
#
FROM alpine:latest AS builder
WORKDIR /my-go-app

#RUN GOOS=linux GOARCH=amd64 go build ./cmd/app-service

RUN apk update
RUN apk add --no-cache git go openssl
#
RUN git clone --progress https://git.sr.ht/~yotam/shavit /my-go-app/shavit_git
#
# 0.0.0.0:1965 - patch for docker. temporary. fixme
#
RUN sed -i 's/gemini.ListenAndServe(""/gemini.ListenAndServe("0.0.0.0:1965"/g' /my-go-app/shavit_git/main.go
RUN cd /my-go-app/shavit_git && go build -o /my-go-app/app-service
# && chmod +x /usr/bin/shavit && rm -rf /my-go-app/shavit_git

#
ADD config.toml /my-go-app/config.toml

# generating random server certs. temporary. fixme
# more examples here:
#
# https://reisub.nsupdate.info/x/makeworld.space/gemlog/2020-07-06-openssl.gmi
# openssl req -new -subj "/CN=*.example.com" -addext "subjectAltName = DNS:example.com, DNS:*.example.com" -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -days 1825 -nodes -out cert.pem -keyout key.pem

RUN openssl req -new -subj "/CN=*.localhost" -addext "subjectAltName = DNS:localhost, DNS:*.localhost" -x509 \
 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -days 90 -nodes -out /my-go-app/server.crt -keyout /my-go-app/server.key
#&& chmod 644 /var/gemini/server.crt /var/gemini/server.key

RUN apk del --no-cache git go openssl make libc-utils
#
# ( STAGE 1 DONE )
#

#
# Complete image ( STAGE 2 )
#
FROM alpine:latest

# Chmod 1550 (chmod a+rwx,u-w,g-w,o-rwx,ug+s,+t,u-s,g-s) (Sticky Bit  enabled)
RUN mkdir -m 1550 -p /var/gemini/docs /etc/shavit
# copy from builder container
COPY --chmod=1550 --from=builder /my-go-app/app-service /usr/bin/shavit
COPY --chmod=1550 --from=builder /my-go-app/server.crt /var/gemini/server.crt
COPY --chmod=1550 --from=builder /my-go-app/server.key /var/gemini/server.key
COPY --chmod=1550 --from=builder /my-go-app/config.toml /etc/shavit/config.toml
# set user:group rights
RUN chown 991:991 /etc/shavit/config.toml /var/gemini/server.key /var/gemini/server.crt /usr/bin/shavit

#
# Create the gemini user
#
ARG UID=991
ARG GID=991
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN addgroup -g $GID shavitt && adduser -u $UID -D -H -G shavitt shavitt && \
	echo "shavitt:$(tr -dc _A-Z-a-z-0-9  < /dev/urandom | head -c 64)" | chpasswd

################################################################################
#
# Cleaning
#
RUN rm -rf /var/cache/apk/*

#
# Hardering, https://gist.github.com/kost/017e95aa24f454f77a37
#

# Remove world-writable permissions.
# This breaks apps that need to write to /tmp,
# such as ssh-agent.
RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} +
RUN find / -xdev -type f -perm +0002 -exec chmod o-w {} +
# Remove unnecessary user accounts.
RUN sed -i -r '/^(user|root|sshd)/!d' /etc/group
#RUN sed -i -r '/^(root|sshd)/!d' /etc/passwd
# Remove interactive login shell for everybody but user.
RUN sed -i -r '/^user:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd


# Remove apk configs.
RUN find /bin /etc /lib /sbin /usr -xdev -regex '.*apk.*' -exec rm -fr {} +

# Remove crufty...
#   /etc/shadow-
#   /etc/passwd-
#   /etc/group-
RUN find /bin /etc /lib /sbin /usr -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
RUN find /bin /etc /lib /sbin /usr -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove all suid files.
RUN find /bin /etc /lib /sbin /usr -xdev -type f -a -perm +4000 -delete

# Remove other programs that could be dangerous.
RUN find /bin /etc /lib /sbin /usr -xdev \( \
  -name hexdump -o \
  -name chgrp -o \
  -name chmod -o \
  -name chown -o \
  -name ln -o \
  -name od -o \
  -name strings -o \
  -name su \
  \) -delete

# Remove init scripts since we do not use them.
RUN rm -fr /etc/init.d
RUN rm -fr /lib/rc
RUN rm -fr /etc/conf.d
RUN rm -fr /etc/inittab
RUN rm -fr /etc/runlevels
RUN rm -fr /etc/rc.conf

# Remove kernel tunables since we do not need them.
RUN rm -fr /etc/sysctl*
RUN rm -fr /etc/modprobe.d
RUN rm -fr /etc/modules
RUN rm -fr /etc/mdev.conf
RUN rm -fr /etc/acpi

# Remove root homedir since we do not need it.
RUN rm -fr /root

# Remove fstab since we do not need it.
RUN rm -f /etc/fstab

# Remove broken symlinks (because we removed the targets above).
RUN find /bin /etc /lib /sbin /usr -xdev -type l -exec test ! -e {} \; -delete

# Others
RUN rm -rf /sbin/mkfs* /sbin/nologin /usr/bin/nc /usr/bin/xxd /usr/bin/hexdump /bin/su* /bin/ap*
#
# Hardering, https://gist.github.com/kost/017e95aa24f454f77a37
#

################################################################################


# Set the run user
USER shavitt

# ENTRYPOINT ["sh"]
CMD ["/usr/bin/shavit"]
#
# ( STAGE 2 DONE )
#

