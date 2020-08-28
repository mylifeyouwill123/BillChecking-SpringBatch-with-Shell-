#!/bin/bash
APP_NAME=./fileDir/more_thread_split.sh 
SPLIT_NAME=./demo/demo-0.0.1-SNAPSHOT.jar
file1="master"
file2="platform"
array[0]=$file1
array[1]=$file2
APP_NAME2=./fileDir/more_thread_split.sh
usage() {
    echo "case: sh run.sh [start|stop|restart|status]"
    echo "请类似这样执行 ./*.sh start   or  ./*sh restart"
    exit 1
}
# 判断当前服务是否已经启动的函数
is_exist(){
    echo "执行 is_exist 方法"
    pid=`ps -ef|grep $APP_NAME|grep -v grep|awk '{print $2}' ` #根据ps 命令查询当前服务的进程号 赋值给pid"
    if [ -z "${pid}" ]; then #判断pid是否为空
        echo "pid 等于null"
        return 1
    else
        echo "pid 不等于null"
        return 0
    fi
}

start(){
    is_exist
    if [ $? -eq "0" ]; then    # [$? -eq "0"] 说明pid不等于空 说明服务正在运行中，将进程号打印出来
        echo "${APP_NAME} running. pid=${pid}"
    else
        echo "--开始文件分割"
        for i in "${!array[@]}";
        do
        {   echo "    正在分割${array[$i]}文件..."
            `./$APP_NAME ${array[$i]} > ./log/${array[$i]}log.file 2>./log/${array[$i]}log.error`
        }&
        done
        wait
        echo "--文件分割结束"
        #nohup ./$APP_NAME $file1 > ./log/masterlog.file 2>./log/masterlog.error &  # 说明pid为空 执行java -jar 命令启动服务
        #nohup ./$APP_NAME $file2 > ./log/platformlog.file 2>./log/platformlog.error &
        echo "${APP_NAME} started"

        if [[ -d "./demo/master/" ]]
            then
            `rm -rf "./demo/master/"`
        fi
        `mv ./fileDir/master/ ./demo/`

        if [[ -d "./demo/platform/" ]]
            then
            `rm -rf "./demo/platform/"`
        fi
        `mv ./fileDir/platform/ ./demo/`
    
        `source "./fileDir/rmTempFile.sh"`
        echo "--数据清理完成"
        echo "--开始执行批处理任务"
        echo "  正在批处理..."
        #`source "./run_springbatch.sh"`
        nohup java -jar $SPLIT_NAME > ./springbatchlog.file 2>./springbatchlog.error &  # 说明pid为空 执行java -jar 命令启动服务
        echo "--批处理任务结束"
    fi
}
stop(){
    echo "执行 stop 方法"
    is_exist
    if [ $? -eq "0" ]; then    # [$? -eq "0"] 说明pid不等于空 说明服务正在运行中，将进程号杀死
        kill -9 $pid
        echo "${pid} stopped"
    else
        echo "${APP_NAME} not running"
    fi
}
 
 
status(){
    echo "执行 status 方法"
    is_exist
    if [ $? -eq "0" ]; then
        echo "${APP_NAME} running. Pid is ${pid}"
    else
        echo "${APP_NAME} not running"
    fi
}
 
 
# 重启命令其实就是先执行关闭命令 再执行重启命令
restart(){
    stop
    start
}
 
 
# 这里的$1 取的是当前输入命令 的第二个参数 ./start.sh start
case $1 in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "status")
        status
        ;;
    "restart")
        restart
        ;;
    *)
    usage
    ;;
esac