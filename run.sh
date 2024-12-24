#!/bin/bash
mkdir -p /var/spool/postfix/pid /var/spool/postfix/dev /var/spool/postfix/private /var/spool/postfix/public 
chown root: /var/spool/postfix/

chown root: /var/spool/postfix/pid;

chown -R postfix:postdrop /var/spool/postfix/private;
chown -R postfix:postdrop /var/spool/postfix/public;

ls -al /var/spool/*

# postfix set-permissions complains if documentation files do not exist
postfix -c /etc/postfix/ set-permissions > /dev/null 2>&1 || true
exec /usr/sbin/postfix -c /etc/postfix start-fg
