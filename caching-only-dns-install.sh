#!/bin/bash
#########################################################################################################################
##  Title: How to quickly install a caching only dns server. It forwards is requests to other servers and does not
##  maintain a dns records to resolve querries itself
#########################################################################################################################
# 1. Install the bind package
yum -y install bind

# 2. Backup /etc/named.conf config file!!!
cp /etc/named.conf /etc/named.conf.predns

# 3. Edit /etc/named.conf. Replace 127.0.0.1 with 'any' or just overwrite the original named file like so:

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
        listen-on port 53 { any; };          # Main line to change; to a specific dns server, e.g in quick dns redirect
        listen-on-v6 port 53 { ::1; };       # You can comment this out if IPV6 is not used in your env.
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };                       # You can specify a specific IP, but any is good
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

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key"
EOF


#4. Enable named service accross reboots and start the service

chkconfig named on && service named start

#5. Test name resolution. Not necessary but it should spit up a lot!!!
netstat -ntul

# 6. test dns queries agains this caching only DNS server
dig @localhost www.google.com

# Log into a remote server and run dns quesries against the caching only dns server
# ssh -v 192.168.1.23
# dig @192.168.1.53 www.google.com 
# End


















