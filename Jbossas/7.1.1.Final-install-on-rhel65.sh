#!/bin/bash
# Step 1: JDK installation and verification
yum -y install java-1.6.0-openjdk-devel
java -version

# Step 2: Download JBoss and the installation procedure
cd /tmp
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip
unzip jboss-as-7.1.1.Fincal.zip -d /usr/share

# 3. Add a new user and group for jboss
groupadd jboss-as
useradd -s /bin/bash -g jboss-as -d /usr/share/jboss-as-7.1.1.Final jboss-as
# Change ownership of the JBoss home directory so all files are owned by the user jboss-as
chown -Rf jboss-as.jboss-as /usr/share/jboss-as-7.1.1.Final

# Step 3: Create the appropriate user
adduser -p afunde21 jboss
chown -fR jboss.jboss /usr/share/jboss-as-7.1.1.Final/
su - jboss
cd /usr/share/jboss-as-7.1.1.Final/bin/      #contains all scripts to start/stop/manage jboss
# Add jboss management user
./add-user.sh        

# 4. Move the startup script provided with the package and the configuration file to respective directories.
 mkdir /etc/jboss-as
 cd /usr/share/jboss-as/bin/init.d
 cp jboss-as.conf /etc/jboss-as/
 cp jboss-as-standalone.sh /etc/init.d/jboss-as

# 5. Backup before you make any changes
cp /etc/jboss-as/jboss-as.conf  /etc/jboss-as/jboss-as.conf.bak
cp /etc/init.d/jboss-as/jboss-as-standalone.sh  /etc/init.d/jboss-as/jboss-as-standalone.sh.bak

#6. Uncomment jboss_user and jboss_console
cat >> /etc/jboss-as/jboss-as.conf << EOF
JBOSS_USER=jboss-as
JBOSS_CONSOLE_LOG=/var/log/jboss-as/console.log
EOF

# 7. Start jboss server and enable persistence accross reboots
chmod 755 /etc/init.d/jboss-as
chkconfig --add jboss-as
chkconfig --level 234 jboss-as on
/etc/init.d/jboss-as start

# 8. Run netstat to confirm jboss starts listening on 8080, by default the server listens on the loopback address, 
# to change this behavior edit standalone.xml file. 

netstat -tunlp | grep 8080
#tcp 0 0 127.0.0.1:8080 0.0.0.0:* LISTEN 55856/java 

#9. Backup and Change jboss bind address for management and public interfaces to ip address it should listen on
# Changed it to 0.0.0.0 so that it listens on every available interface.
 
cp /usr/share/jboss-as/standalone/configuration/standalone.xml /usr/share/jboss-as/standalone/configuration/standalone.xml.bak
cat > /usr/share/jboss-as/standalone/configuration/standalone.xml << EOF
< interfaces>
 <interface name="management">
 <inet-address value="${jboss.bind.address.management:0.0.0.0}"/>
 </interface>
 <interface name="public">
 <inet-address value="${jboss.bind.address:0.0.0.0}"/>
 </interface>
 <!-- TODO - only show this if the jacorb subsystem is added -->
 < interface name="unsecure">
 <!--
~ Used for IIOP sockets in the standard configuration.
 ~ To secure JacORB you need to setup SSL
 -->
 <inet-address value="${jboss.bind.address.unsecure:127.0.0.1}"/>
 </interface>
 </interfaces>
EOF

# 10. Try to Access Jboss Management Interface at http://ipaddress-or-domainname:9990
# Mesaage: Your jboss application server is running. However you have not yet added any users to be able to access the admin console.
# Add an initial Management User (mgmt-users.properties) user:
cd /usr/share/jboss-as/bin/
