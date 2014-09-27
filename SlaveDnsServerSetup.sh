#!/bin/bash
#########################################################################################################################
# Author: Athanasius C. Kebei
#Title: Slave DNS Server Installation and Setup 
#
# References:
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/ch-DNS_Servers.html
# http://www.server-world.info/en/note?os=CentOS_6&p=dns&f=6
# http://www.unixmen.com/dns-server-installation-step-by-step-using-centos-6-3/
# http://www.server-world.info/en/note?os=CentOS_6&p=dns&f=6
# http://ostechnix.wordpress.com/2013/12/15/setup-dns-server-step-by-step-in-centos-6-3-rhel-6-3-scientific-linux-6-3-3/
########################################################################################################################
yum -y install bind bind-utils
cp /etc/named.conf /etc/named.conf.predns

cat > /etc/named.conf << EOF
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
options {
listen-on port 53 { 127.0.0.1; 192.168.1.19; };                                   ## Slave DNS IP ##      
listen-on-v6 port 53 { ::1; };
directory "/var/named";
dump-file "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
allow-query     { localhost; 192.168.1.0/24; };                                   ## IP Range ##   
recursion yes;
dnssec-enable yes;
dnssec-validation yes;
dnssec-lookaside auto;
/* Path to ISC DLV key */
bindkeys-file "/etc/named.iscdlv.key";
managed-keys-directory "/var/named/dynamic";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
type hint;
file "named.ca";
};
zone"neustar.net" IN {
type slave;
file "slaves/neustar.fwd";
masters { 192.168.1.53; };
};
zone"1.168.192.in-addr.arpa" IN {
type slave;
file "slaves/neustar.rev";
masters { 192.168.1.19; };
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

chkconfig named on && service named start

# Tests
ls /var/named/slaves/neustar.fwd
cat /var/named/slaves/neustar.fwd


#7.Test syntax errors of DNS configuration and zone files
# Check DNS Config file
named-checkconf /etc/named.conf
named-checkconf /etc/named.rfc1912.zones

# Check zone files 
named-checkzone neustar.net /var/named/fwd.neustarx.net
named-checkzone neustar.net /var/named/rev.neustar.net 

# Test DNS Server: 3 methods dig hostname, dig ip, nslookup:
dig masterdns.neustar.net
dig -x 192.168.1.53
dig -x 192.168.1.19
nslookup masterdns
nslookup 2ndrydns

cat > /etc/resolv.conf << EOF
domain neustar.net
search neustar.net
nameserevr 192.168.1.53
nameserver 192.168.1.19
nameserver 208.67.222.222
nameserver 8.8.8.8
EOF
chkconfig NetworkManager off && service NetworkManager stop






