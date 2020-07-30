# yumdownloader --archlist=x86_64 --destdir=iso-temp/Packages/ `cat project/rpm.list`
iso_dir=iso-tmp

/usr/bin/rsync -a --exclude=Packages/ --exclude=repodata/ ./centos_tree  ${iso_dir}

cp config/isolinux.cfg ${iso_dir}/isolinux/
cp config/ks.cfg ${iso_dir}/isolinux/

cd ${iso_dir} && createrepo -g repodata/comps.xml ./ && cd ..


genisoimage -joliet-long -V CentOS7 -o CentOS-7-4.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -cache-inodes -T -eltorito-alt-boot -e images/efiboot.img -no-emul-boot ./iso-tmp


implantisomd5 ./CentOS-7-4.iso


scp ./CentOS-7-4.iso  192.168.20.104:~/Downloads