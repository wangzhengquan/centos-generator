
# file:///home/wzq/CentosDVD2/BaseOS/ \
#	file:///home/wzq/CentosDVD2/AppStream/ \

# http://mirrors.aliyun.com/centos/8/BaseOS/x86_64/os/ \
#	http://mirrors.aliyun.com/centos/8/AppStream/x86_64/os/ \

# https://mirrors.163.com/fedora/releases/33/Everything/x86_64/os/
# https://mirrors.163.com/fedora/updates/33/Everything/x86_64/


REPO="mirrors.163.com/fedora/releases/33/Everything/x86_64/os"
REPO2="mirrors.163.com/fedora/updates/33/Everything/x86_64"
PROTOCL=https
OUTPUTDIR=`pwd`/build
LORAXBASE=/home/wzq/wk/lorax

function update_repo() {

  REPO_BASE="/home/wzq/CentosDVD2/AppStream"

  # rpmbuild -bb /home/wzq/wk/anaconda/anaconda.spec
  # cp /home/wzq/rpmbuild/RPMS/x86_64/anaconda* ${REPO_BASE}/Packages/
  work_dir=`pwd`
  tmp_comps_xml=`pwd`/comps-AppStream.x86_64.xml
  chmod -R  +rwX ${REPO_BASE} ; # createrepo demand
  # compsxml=`cd ${REPO_BASE}; find repodata -name '*-x86_64-comps*.xml'`; \
  # compsxml=`cd ${REPO_BASE}; find repodata -name '*comps-AppStream.x86_64.xml'`; \
  compsxml=`find ${REPO_BASE}/repodata -name '*comps-AppStream.x86_64.xml'`; \
  cp ${compsxml} ${tmp_comps_xml}; \
  test -f ${tmp_comps_xml} || exit 1; \
  rm ${REPO_BASE}/repodata/*.bz2 ${REPO_BASE}/repodata/*.gz ${REPO_BASE}/repodata/*.xz; \
  # cp ${tmp_comps_xml} ${REPO_BASE}/repodata/comps.xml; \
  cd ${REPO_BASE} && createrepo --xz  -v -g ${tmp_comps_xml} . && cd ${work_dir}

  if [ $? != 0 ];then
	exit -1
  fi

  rm -f ${tmp_comps_xml}
}


function update_repo() {

  REPO_BASE="/home/wzq/CentosDVD2/AppStream"

  # rpmbuild -bb /home/wzq/wk/anaconda/anaconda.spec
  # cp /home/wzq/rpmbuild/RPMS/x86_64/anaconda* ${REPO_BASE}/Packages/
  work_dir=`pwd`
  tmp_comps_xml=`pwd`/comps-AppStream.x86_64.xml
  chmod -R  +rwX ${REPO_BASE} ; # createrepo demand
  # compsxml=`cd ${REPO_BASE}; find repodata -name '*-x86_64-comps*.xml'`; \
  # compsxml=`cd ${REPO_BASE}; find repodata -name '*comps-AppStream.x86_64.xml'`; \
  compsxml=`find ${REPO_BASE}/repodata -name '*comps-AppStream.x86_64.xml'`; \
  cp ${compsxml} ${tmp_comps_xml}; \
  test -f ${tmp_comps_xml} || exit 1; \
  rm ${REPO_BASE}/repodata/*.bz2 ${REPO_BASE}/repodata/*.gz ${REPO_BASE}/repodata/*.xz; \
  cp ${tmp_comps_xml} ${REPO_BASE}/comps-AppStream.x86_64.xml; \
  cd ${REPO_BASE} && createrepo --xz  -v -g comps-AppStream.x86_64.xml ${REPO_BASE} && cd ${work_dir}

  if [ $? != 0 ];then
	exit -1
  fi

  rm -f ${tmp_comps_xml}
}

function build() {

	
	
	export PYTHONPATH=${PYTHONPATH}:${LORAXBASE}/src/
	export PATH=${LORAXBASE}/src/sbin:${LORAXBASE}/src/bin:${PATH}

	echo "PYTHONPATH=${PYTHONPATH}"
	echo "PATH=${PATH}"

	rm -rvf ${OUTPUTDIR}
	rm -f   `pwd`/*.log
	rm -rf `pwd`/tmp
	rm -rf /var/tmp/lorax.*
   

	setenforce 0

	python3 ${LORAXBASE}/src/sbin/lorax -p "AIOS" -v 8 -r 8  --nomacboot  --volid="AIOS"  --isfinal \
	--sharedir ${LORAXBASE}/share/templates.d/99-generic \
  --config ${LORAXBASE}/etc/lorax.conf \
	-s ${PROTOCL}://${REPO} \
	-s ${PROTOCL}://${REPO2} \
	--tmp `pwd`/tmp \
	${OUTPUTDIR}

	if [ $? != 0 ];then
	  exit -1
	fi

	chown -R $LOGNAME ${OUTPUTDIR}
	chmod -R +w       ${OUTPUTDIR}
	echo "genimg success!"
}


function build_livemedia() {
  export PYTHONPATH=${PYTHONPATH}:${LORAXBASE}/src/
  export PATH=${LORAXBASE}/src/sbin:${LORAXBASE}/src/bin:${PATH}

  rm -f   `pwd`/*.log

  setenforce 0

  python3  ${LORAXBASE}/src/sbin/livemedia-creator --make-iso \
  --lorax-templates ${LORAXBASE}/share/templates.d/99-generic \
  --iso=boot.iso --ks=${LORAXBASE}/docs/fedora-livemedia.ks
}

function usage() {
  echo "Usage: ${0} [update_repo | build]"
}

case ${1} in
  "update_repo")
  update_repo
  ;;
  "build")
  build 
  ;;
  "")
  build_livemedia
  ;;
  *)
  usage ${0}
  exit 1
  ;;
esac
