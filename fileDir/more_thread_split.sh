#!/bin/bash
root=/home/zk/fastpay/
workDir=/home/zk/fastpay/fileDir/
resultDir=$workDir$1"/"
rawDir=$workDir"rawDataDir/"
tempDir=$workDir$1"tempDir/"
rawData=$rawDir$1
totalLines=`wc -l $rawData|cut -d " " -f1`
#设置线程数目
thread=10
#按照流水号后两位排序
#sort -t ',' -k2 $rawData >/dev/null 2>&1F
date
#检查目录是否创建，若无则先创建
if [[ ! -d $resultDir ]]
then
	`mkdir $resultDir`
fi
if [[ ! -d $tempDir ]]
then
	`mkdir $tempDir`
fi
echo "PID="$$"----目录检查完毕"
#设置步长step（每个子文件的行数），向上取整
function ceil(){
	echo $1 | awk '{print int($1)==$1?int($1):int(int($1)+1)}'
}
stepp=`awk 'BEGIN{ printf "%.5f\n", '$totalLines'/'$thread'}'`
step=`ceil $stepp`
#-------------------------------------------------------------
#分割大文件为10个小文件，每个文件$step行
`split -l $step $rawData -d -a 3 target$1`
#-------------------------------------------------------------
#多线程：根据流水号后两位ID分割文件
for((i=0;i<$thread;i++))
do
{
	#echo "PID="$!"----线程"$i"启动"
	#字符串拼接：设置每个线程的工作目录dir[i]和日志文件名
	dir=$tempDir"dir"$i"/"
	log=$dir"log"
	#字符串拼接：生成线程i要处理的文件名
	num=`printf "%03d" $i`
	target=$root"target"$1$num
	
	#根据线程自己的log,判断是否续传
	if [[ -s "$log" ]]
	then
		line=`tail -n 1 $log`
		if [[ $line =~ [1-9][0-9]*$ ]]
		then
			line=`expr $line + 1`
			echo "PID="$!"----线程"$i":从第"`expr $line`"行续传"
		else
			echo "PID="$!"----线程"$i":log not number"
		fi	
	else
		line="1"
		echo "PID="$!"----线程"$i"新任务启动"
	fi

	if [[ ! -d $dir ]]
	then
		`mkdir $dir`
	fi
	#awk处理文件[print $0 >> "'$dir'"substr($2,length($2)-1);]
	awk -F , 'BEGIN{x="'$line'"} NR=x {
		print $0 >> "'$dir'"substr($0,26,2);
		print NR >> "'$log'";
		x=x+1
	} END{print "'线程'"'$i'"'文件分割完毕'"}' $target
}&
done
wait
#-------------------------------------------------------------
#多线程：相同编号的文件合并
echo "PID="$$"----所有线程文件分割完毕,即将多线程合并..."
for((i=0;i<100;i++))
do
{
	num=`printf "%02d" $i`
	#拼接字符串
	for((j=0;j<$thread;j++))
	do
	{
		if [[ -f $tempDir"dir"$j"/"$num ]]
		then
			printf $tempDir"dir"$j"/"$num" " >> $tempDir"temp"$i
			
		fi
	}
	done
	#合并文件，并排序、去重
	if [[ -f $tempDir"temp"$i ]]
	then
		`sed -i 's/ *$//' $tempDir"temp"$i`
		file=`cat $tempDir"temp"$i`
		`cat $file > $tempDir$num`
		#排序去重
		`sort -t ',' -k2 $tempDir$num | uniq > $resultDir$num`
	fi
}&
done
wait
echo "PID="$$"----文件合并完成"
#中间数据清理
`source $workDir"rmTempFile.sh"`
echo "PID="$$"----数据清理完成"
date
