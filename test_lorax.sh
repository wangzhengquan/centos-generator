
# -s file:///home/wzq/CentosDVD2/BaseOS/ \
#	-s file:///home/wzq/CentosDVD2/AppStream/ \

# -s http://mirrors.aliyun.com/centos/8/BaseOS/x86_64/os/ \
#	-s http://mirrors.aliyun.com/centos/8/AppStream/x86_64/os/ \

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

function run() {

	OUTPUTDIR=`pwd`/img
	LORAXBASE=/home/wzq/wk/lorax
	export PYTHONPATH=${PYTHONPATH}:${LORAXBASE}/src/
	export PATH=${LORAXBASE}/src/sbin:${LORAXBASE}/src/bin:${PATH}

	echo "PYTHONPATH=${PYTHONPATH}"
	echo "PATH=${PATH}"

	rm -rvf ${OUTPUTDIR}
	rm -f   `pwd`/*.log
	rm -rf `pwd`/tmp
	rm -rf /var/tmp/lorax.*

	setenforce 0

 	#-s file:///home/wzq/CentosDVD2/BaseOS/ \
	#-s file:///home/wzq/CentosDVD2/AppStream/ \
	python3 ${LORAXBASE}/src/sbin/lorax -p "AIOS" -v 8 -r 8  --nomacboot  --volid="AIOS"  --isfinal \
	--sharedir ${LORAXBASE}/share \
	-s http://192.168.20.104/centos8/BaseOS \
	-s http://192.168.20.104/centos8/AppStream \
	--tmp `pwd`/tmp \
	${OUTPUTDIR}

	if [ $? != 0 ];then
	  exit -1
	fi

	chown -R $LOGNAME ${OUTPUTDIR}
	chmod -R +w       ${OUTPUTDIR}
	echo "genimg success!"
}

function usage() {
  echo "Usage: ${0} [update_repo | run]"
}

case ${1} in
  "update_repo")
  update_repo
  ;;
  "run")
  run 
  ;;
  "")
  run
  ;;
  *)
  usage ${0}
  exit 1
  ;;
esac
