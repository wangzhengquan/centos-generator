#!/bin/bash


#BuildID="$(date +%Y%m%d)"
ProduceName=AIOS
ReleaseID=8
DVD=/home/wzq/CentosDVD2
mirror=file://${DVD}
dist=./build
# mirror=http://mirror.centos.org/centos-7/7/os/x86_64/
export LC_ALL=C
function do_clean
{
  #yum clean all && yum update
  rm -rvf ${dist}
  rm -f   ./*.log
  rm -rf /var/tmp/lorax.*
  # for i in `ls /dev/loop[0-9]*`
  # do
  #    losetup -d $i 2>/dev/null
  #    umount $i 2>/dev/null  
  # done

}


function create_repo1() {
  test  -d ${DVD} || mkdir ${DVD}
  sudo yumdownloader `rpm -qa`  --destdir=${DVD}/Packages
  #sudo yumdownloader `cat config/install.list`  --destdir=${DVD}/Packages

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


function create_repo() {
  test  -d ${DVD} || mkdir ${DVD}
  #sudo yumdownloader `rpm -qa`  --destdir=${DVD}/Packages
  sudo yumdownloader `cat config/install.list`  --destdir=${DVD}/Packages

  chmod -R +rwX ${DVD}/repodata
  chmod +rwX ${DVD} ; # createrepo demand
  test -f ./comps8.xml || exit 1; \
  rm ${DVD}/repodata/*.bz2 ${DVD}/repodata/*.gz; \
  cp ./comps8.xml ${DVD}/repodata/comps.xml; \
  createrepo -v -g repodata/comps.xml ${DVD}
}


function build() {

  do_clean

  setenforce 0
  /home/wzq/wk/lorax/src/sbin/lorax -p "${ProduceName}" -v ${ReleaseID} -r ${ReleaseID}  --nomacboot  --volid="${ProduceName}"  --isfinal \
  -s file:///home/wzq/CentosDVD2/BaseOS/ \
  -s ${mirror} \
  ${dist}

  if [ $? != 0 ];then
    exit -1
  fi

  chown -R $LOGNAME ${dist}
  chmod -R +w       ${dist}
  echo "build success!"
}



function geniso() {
  
  # rm -rf ${dist}/{BaseOS, AppStream}
  # cp -a ${DVD}/BaseOS ${DVD}/AppStream ${dist}
  cp ${DVD}/media.repo ${dist}
  rm -rf ${dist}/BaseOS/Packages/*.i686.rpm
  rm -rf ${dist}/AppStream/Packages/*.i686.rpm
  rm -rf ${dist}/images/boot.iso

  # cd ${dist}/ && createrepo -g ../config/custome_comps.xml . && cd ../

  rm -rf *.iso
  # Create the new ISO file.
  genisoimage -U -r -v -T -J -joliet-long                                      \
              -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}       \
              -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
              -no-emul-boot -boot-load-size 4 -boot-info-table                 \
              -eltorito-alt-boot -e images/efiboot.img -no-emul-boot           \
              -o ./${ProduceName}-${ReleaseID}.iso \
              ${dist}    

  # genisoimage -U -r -v -T -J -joliet-long                                      \
  #             -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}       \
  #             -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
  #             -no-emul-boot -boot-load-size 4 -boot-info-table                 \
  #             -eltorito-alt-boot -no-emul-boot           \
  #             -o ./${ProduceName}-${ReleaseID}.iso \
  #             ${dist}    


  if [ $? != 0 ];then
    echo 'genisoimage failed.'
    exit $?
  fi

# (Optional) Use isohybrid if you want to dd the ISO file to a bootable USB key.
  isohybrid ./${ProduceName}-${ReleaseID}.iso


  # Add an MD5 checksum (to allow testing of media).
  implantisomd5 ./${ProduceName}-${ReleaseID}.iso

  scp  ./${ProduceName}-${ReleaseID}.iso 192.168.20.104:~/Downloads/
  echo "geniso success!"
}


function usage() {
  echo "Usage: ${0} [geniso | build]"
}


case ${1} in
  "genrepo")
  create_repo
  ;;
  "geniso")
  geniso
  ;;
  "build")
  build
  ;;
  "all")
  create_repo
  build
  geniso
  ;;
  "")
  build
  geniso
  ;;
  *)
  usage ${0}
  exit 1
  ;;
esac
