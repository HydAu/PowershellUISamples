LOG_FILE='last_run_report.yaml'
STATEDIR='/home/sergueik/test'

pushd $STATEDIR
ls -la ${LOG_FILE}.* 
FILE_COUNT=$(ls -la $LOG_FILE.* | wc -l)
echo "FILE_COUNT=${FILE_COUNT}"
CNT=$FILE_COUNT
while [ $CNT -gt 0  ]
	do 
		NEXT_CNT=$(expr $CNT + 1)
		cp $LOG_FILE.$CNT $LOG_FILE.$NEXT_CNT 
		CNT=$(expr $CNT - 1)
	done
popd
cp $LOG_FILE "${LOG_FILE}.1"
