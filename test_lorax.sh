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

python3 ${LORAXBASE}/src/sbin/lorax -p "AIOS" -v 8 -r 8  --nomacboot  --volid="AIOS"  --isfinal \
-s file:///home/wzq/CentosDVD2/BaseOS/ \
-s file:///home/wzq/CentosDVD2/AppStream/ \
--sharedir ${LORAXBASE}/share \
--tmp `pwd`/tmp \
${OUTPUTDIR}

if [ $? != 0 ];then
  exit -1
fi

chown -R $LOGNAME ${OUTPUTDIR}
chmod -R +w       ${OUTPUTDIR}
echo "genimg success!"