# yumdownloader --archlist=x86_64 --destdir=iso-temp/Packages/ `cat project/rpm.list`
img=./img
DVD=/data/centos_tree

/usr/bin/rsync -a --exclude=Packages/ --exclude=repodata/  ${DVD}  ${img}
mkdir -p ${img}/{Packages,repodata}

cp -a ${DVD}/Packages/*  ${img}/Packages
cp config/isolinux.cfg ${img}/isolinux/
cp config/ks.cfg ${img}/isolinux/

cd ${img} && createrepo -g repodata/comps.xml ./ && cd ..


genisoimage -joliet-long -V CentOS7 -o CentOS-7-4.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot\
 	-boot-load-size 4 -boot-info-table -R -J -v -cache-inodes -T -eltorito-alt-boot \
 	-e images/efiboot.img -no-emul-boot ${img}


implantisomd5 ./CentOS-7-4.iso


scp ./CentOS-7-4.iso  192.168.20.104:~/Downloads