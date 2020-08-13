#!/bin/bash


#BuildID="$(date +%Y%m%d)"
ProduceName=AIOS
ReleaseID=7
DVD=/data/centos_tree
mirror=file://${DVD}
# mirror=http://192.168.20.104
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


function create_repo() {
  # sudo yumdownloader `rpm -qa`  --destdir=${DVD}/Packages
  sudo yumdownloader `cat config/install.list`  --destdir=${DVD}/Packages

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

  do_clean

  if sestatus |grep -E "Current mode:.*enforcing";then
  setenforce 0
  fi

  /home/wzq/wk/lorax/src/sbin/lorax -p "${ProduceName}" -v ${ReleaseID} -r ${ReleaseID} --volid="${ProduceName}"  --isfinal \
  -s ${mirror} \
  ${img}

  if [ $? != 0 ];then
    exit -1
  fi


  # chown -R $LOGNAME ${img}
  # chmod -R +w       ${img}
}



function geniso() {
  
  # rm -rf ${img}/Packages
  # mkdir -p ${img}/{Packages,repodata}
  # cp -a ${DVD}/Packages/* ${img}/Packages
  # rm -rf ${img}/Packages/*.i686.rpm
  # rm -rf  ${img}/images/boot.iso
 mkdir -p ${img}/{Packages,repodata}
 cd ${img}/ && createrepo -g ../config/custome_comps.xml . && cd ../

  rm -rf *.iso
  # Create the new ISO file.
  genisoimage -U -r -v -T -J -joliet-long                                      \
              -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}       \
              -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
              -no-emul-boot -boot-load-size 4 -boot-info-table                 \
              -eltorito-alt-boot -e images/efiboot.img -no-emul-boot           \
              -o ./${ProduceName}-${ReleaseID}.iso \
              ${img}    


  # (Optional) Use isohybrid if you want to dd the ISO file to a bootable USB key.
  isohybrid ./${ProduceName}-${ReleaseID}.iso


  # Add an MD5 checksum (to allow testing of media).
  implantisomd5 ./${ProduceName}-${ReleaseID}iso

  scp  ./${ProduceName}-${ReleaseID}.iso wzq@192.168.20.104:~/Downloads/
}


function usage() {
  echo "Usage: ${0} [geniso | genimg]"
}


case ${1} in
  "create_repo")
  create_repo
  ;;
  "geniso")
  geniso
  ;;
  "genimg")
  genimg
  ;;
  "all")
  create_repo
  genimg
  geniso
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