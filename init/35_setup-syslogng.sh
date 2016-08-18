#!/bin/bash
[[ ! -f /etc/syslog-ng/conf.d/haproxy.conf ]] && cp /defaults/haproxy.conf-syslogng /etc/syslog-ng/conf.d/haproxy.conf || echo "HaProxy Syslog config already set"
