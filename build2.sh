#!/bin/bash


BuildID="$(date +%Y%m%d)"
ProduceName=AIOS
ReleaseID=7
DVD=/data/centos_tree
mirror=file://${DVD}
img=./img
# mirror=http://mirror.centos.org/centos-7/7/os/x86_64/
export LC_ALL=C
function do_clean
{
  #yum clean all && yum update
  rm -rvf ${img}
  rm -f   ./*.log
  rm -rf /var/tmp/lorax.*
  # for i in `ls /dev/loop[0-9]*`
  # do
  #    losetup -d $i 2>/dev/null
  #    umount $i 2>/dev/null  
  # done

}


function re_create_repo() {
  sudo yumdownloader `cat config/pkg.list`  --destdir=${DVD}/Packages

  chmod -R +rwX ${DVD}/repodata
  chmod +rwX ${DVD} ; # createrepo demand
  compsxml=`cd ${DVD}; find repodata -name '*-x86_64-comps*.xml'`; \
  rm -f ./comps.xml; \
  cp ${DVD}/${compsxml} ./comps.xml; \
  test -f ./comps.xml || exit 1; \
  rm ${DVD}/repodata/*.bz2 ${DVD}/repodata/*.gz; \
  cp ./comps.xml ${DVD}/repodata/comps.xml; \
  createrepo -v -g repodata/comps.xml ${DVD}
}


function genimg() {

  
  re_create_repo

  do_clean

  if sestatus |grep -E "Current mode:.*enforcing";then
  setenforce 0
  fi

  sudo lorax -p "${ProduceName}" -v ${ReleaseID} -r ${ReleaseID} --nomacboot  --volid="${ProduceName}"  --isfinal \
  -s ${mirror} \
  ${img}

  if [ $? != 0 ];then
    exit -1
  fi


  mkdir -p ${img}/{Packages,repodata}

  #cp -rf ${DVD}/Packages/*.rpm  ${img}/Packages
  #rm -rf ${img}/Packages/*.i686.rpm
  # rm -rf  ${img}/images/boot.iso
  cd ${img}/ && createrepo -g ../config/comps.xml . && cd ../

  chown -R $LOGNAME ${img}
  chmod -R +w       ${img}
}



function geniso() {
  rm -rf *.iso
  cp ${DVD}/images/efiboot.img ${img}/images/

  # Create the new ISO file.
  genisoimage -U -r -v -T -J -joliet-long                                      \
              -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}       \
              -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
              -no-emul-boot -boot-load-size 4 -boot-info-table                 \
              -eltorito-alt-boot -e images/efiboot.img -no-emul-boot           \
              -o ./${ProduceName}-custom-${ReleaseID}-${BuildID}.iso \
              ${img}    


# (Optional) Use isohybrid if you want to dd the ISO file to a bootable USB key.
isohybrid ./${ProduceName}-custom-${ReleaseID}-${BuildID}.iso


# Add an MD5 checksum (to allow testing of media).
 implantisomd5 ./${ProduceName}-custom-${ReleaseID}-${BuildID}.iso

 #scp AIOS-custom-7-20200731.iso 192.168.20.104:~/Downloads/
}


function usage() {
  echo "Usage: ${0} [geniso | genimg]"
}


case ${1} in
  "geniso")
  geniso
  ;;
  "genimg")
  genimg
  ;;
  "")
  genimg
  geniso
  ;;
  *)
  usage ${0}
  exit 1
  ;;
esac