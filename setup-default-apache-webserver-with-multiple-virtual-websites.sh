#!/bin/bash -vvvv
################################################################################################################################
# Title: Install and configure Apache webserver to host multiple virtual Named-hosts websites 
#
# Author: Athanasius C. Kebei
#
# References:
# https://access.redhat.com/discussions/668813
# http://www.tecmint.com/apache-ip-based-and-name-based-virtual-hosting/
################################################################################################################################

yum -y install httpd elinks
lokkit --service http                                  # opens port 80, to use secure https lokkit --service https
chkconfig httpd on && service httpd start

firefox http://localhost                               # Loads default apache webpage in an X-windows env. 
elinks http://localhost                                # From a ssh env

cp /etc/hosts /etc/hosts.preweb                        # Backup !!!
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.preweb

                                                       # Put virtual websites in /etc/hosts to point to localhost
cat > /etc/hosts << EOF
127.0.0.1        neustar1.net      neustar2.net    localhost.localdomain   localhost
::1  localhost6.localdomain     localhost6
EOF
                                                        
                                                         # create root DocumentRoot directories for websites
mkdir -p /var/www/html/neustar1.net
mkdir -p /var/www/html/neustar2.net
ls -Zd /var/www/html                                     # Take quick look at permissions, ownership (only root with rw)
ls -Zd /var/www/html/neustar1.net                        # selinux context to let selinux know httpd  has the right 
ls -Zd /var/www/html/neustar2.net                        # httpd_sys_content_t for unconfined access


                                                         # Create virtual hosts containers in Section 3 of httpd.conf
cat >> /etc/httpd/conf/httpd.conf << EOF
# Use name-based virtual hosting

NameVirtualHost neustar1.net:80

<VirtualHost neustar1.net:80>
    ServerAdmin webmaster@neustar1.net
    DocumentRoot /var/www/html/neustar1.net
    ServerName neustar1.net
    ErrorLog logs/neustar1.net-error_log
    CustomLog logs/neustar1.net-access_log common
</VirtualHost>

NameVirtualHost neustar2.net:80

<VirtualHost neustar2.net:80>
    ServerAdmin webmaster@neustar2.net
    DocumentRoot /var/www/html/neustar2.net
    ServerName neustar2.net
    ErrorLog logs/neustar2.net-error_log
    CustomLog logs/neustar2.net-access_log common
</VirtualHost>
EOF

service httpd configtest                                     # Return should be syntax ok, iter alias. http -t
service httpd restart

                                                             # Create webpage initial content: index.html for websites
cat > /var/www/html/neustar1.net/index.html << EOF
Hyer world, welcome to neustar1.net!!!
EOF

cat > /var/www/html/neustar2.net/ndex.html << EOF
Hyer world, welcome back to neustar2.net!!!
EOF

                                                              # Testing time with web browsers
firefox http://neustar1.net                                   # or elinks http://neustar1.net
firefox http://neustar2.net                                   # or elinks http://neustar2.net
                                                              
                                                              # Voila!



