#!/bin/bash


#BuildID="$(date +%Y%m%d)"
ProduceName=AIOS
ReleaseID=7
DVD=/data/centos_tree
REPO=file://${DVD}
# REPO=http://192.168.20.104
# REPO=http://mirror.centos.org/centos-7/7/os/x86_64/
dest=./build

export LC_ALL=C

function do_clean
{
  #yum clean all && yum update
  rm -rvf ${dest}
  rm -f   ./*.log
  rm -rf /var/tmp/lorax.*
  # for i in `ls /dev/loop[0-9]*`
  # do
  #    losetup -d $i 2>/dev/null
  #    umount $i 2>/dev/null  
  # done

}

# Download conda anaconda-core anaconda-dracut and rebuild repo
# this method need only run one time.
function create_repo() {
  # sudo yumdownloader `rpm -qa`  --destdir=${DVD}/Packages
  sudo yumdownloader `cat config/repo_pkg_centos7.list`  --destdir=${DVD}/Packages

  chmod -R +rwX ${DVD}/repodata
  chmod +rwX ${DVD}  # createrepo demand
  compsxml=`find ${DVD}/repodata -name '*-x86_64-comps*.xml'`
  if test -z compsxml; then
    echo "create_repo failed. could not find x86_64-comps.xml"
    exit -1
  fi
  
  rm ${DVD}/repodata/*.bz2 ${DVD}/repodata/*.gz
  tmp_xml=`mktemp`; \
  cat ${compsxml} > ${tmp_xml}; \
  createrepo -v -g ${tmp_xml} ${DVD}

  echo "create repo success."
}


function build() {

  do_clean

  if sestatus | grep -E "Current mode:.*enforcing";then
    setenforce 0
  fi

  sudo lorax -p "${ProduceName}" -v ${ReleaseID} -r ${ReleaseID} --volid="${ProduceName}"  --isfinal \
  -s ${REPO} ${dest}

  if [ $? != 0 ];then
    echo 'builed failed.'
    exit -1
  fi

  echo 'builed success.'
  # chown -R $LOGNAME ${dest}
  # chmod -R +w       ${dest}
}



function geniso() {
  
  rm -rf ${dest}/Packages
  mkdir -p ${dest}/{Packages,repodata}
  cp -a ${DVD}/Packages/* ${dest}/Packages
  rm -rf ${dest}/Packages/*.i686.rpm
  rm -rf  ${dest}/images/boot.iso

  cp config/ks_centos7.cfg  ${dest}/isolinux/ks.cfg
 # cd ${dest}/ && createrepo -g ../config/comps_centos7_origin.xml . && cd ../

  rm -rf *.iso
  # Create the new ISO file.
  sudo genisoimage -U -r -v -T -J -joliet-long                                      \
              -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}       \
              -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
              -no-emul-boot -boot-load-size 4 -boot-info-table                 \
              -eltorito-alt-boot -e images/efiboot.img -no-emul-boot           \
              -o ./${ProduceName}-${ReleaseID}.iso \
              ${dest}    

  if [ $? != 0 ];then
      echo 'genisoimage failed.'
      exit -1
  fi

  # (Optional) Use isohybrid if you want to dd the ISO file to a bootable USB key.
  isohybrid ./${ProduceName}-${ReleaseID}.iso


  # Add an MD5 checksum (to allow testing of media).
  implantisomd5 ./${ProduceName}-${ReleaseID}.iso

  scp  ./${ProduceName}-${ReleaseID}.iso wzq@192.168.20.104:~/Downloads/
}


function usage() {
  echo "Usage: ${0} [create_repo | geniso | build | all]"
}


case ${1} in
  "create_repo")
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