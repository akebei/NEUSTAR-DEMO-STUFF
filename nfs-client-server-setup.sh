#/bin/bash -vvvvv
#########################################################################################################################
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/ch-nfs.html
#
##########################################################################################################################
# 1. Install NFS Client package
   yum -y install nfs-utils
# 2. Start NFS service in client and enable across reboots         
  service nfs start  &&  chkconfig nfs                       

# 3. Create a directory where you want to mount the nfs share /home/kickstart:
    mkdir -p /nfshares

# 4. Take a look at the nfs share on nfsserver and mount it to nfsclient:
showmount -e 192.168.1.23
mount -t nfs 192.168.1.23:/home/kickstart /nfshares

#Note that this might take quite some time and in some cases connection time errors, because nfsserver firewall might 
# be restricting the nfsclient to mount nfs shares. If this happens, then take a look at the firewall on the 
# nfsserver. Again mount the share from client
mount -t nfs 192.168.1.23:/home/kickstart /nfshares

# Issue the mount command to verify if the NFS share is mounted with no connection timed out errors. If it is, 
# it might/will be the last entry in the result from the mount command.
mount

# 13. Finally, test the NFS Share from nfsclient by cding into it and creating files/folders and writing to them:
cd /nfshares  
mkdir /testfile && touch test1 test2
cat > test1 << EOF
Hyer, we should have a meeting
EOF
# 14. Test synchronization of client files/folders on nfsserver by checking newly created directory/files from 
# nfsclient in the /home/kickstart directory:
cd /home/kickstart && ls                
# If you see these, then you did it
# test1 test2   testfile                         
# Success!! Files and directories created in the server or client auto-sync to and from (client-server-client).

# 15. To have the shares automounted on both client add an entry to /etc/fstab,  reboot nfsclient and verify 
# with the mount command:

cat >> /etc/fstab << EOF                                 
192.168.1 23:/home/kickstart     /mnt/nfs     nfs    _inetdev   0 0
EOF
mount

########################################################################################################################
#  nfs-client-server script clean
########################################################################################################################
#!/bin/bash -vvvvvv
yum -y install nfs-utils
service nfs start  &&  chkconfig nfs
mkdir -p /nfshares
showmount -e 192.168.1.23
mount -t nfs 192.168.1.23:/home/kickstart /nfshares
mount
cd /nfshares  
mkdir /testfile && touch test1 test2

cat > test1 << EOF
Hyer, we should have a meeting
EOF

cat >> /etc/fstab << EOF                                 
192.168.1 23:/home/kickstart     /mnt/nfs     nfs    _inetdev   0 0
EOF
mount
# END

