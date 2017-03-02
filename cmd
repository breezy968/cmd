#!/bin/bash
# Filename : cmd
#使用方法
usage(){
    echo "usage: ./cmd [adb／fastboot ...]"
}
#给每条adb命令加-s ID 参数
cmd(){
if [ $isadb == 1 ]
then
    command1=${command:0:4}"-s ${Num[$i]} "${command:4}
else
    command1=${command:0:9}"-s ${Num[$i]} "${command:9}
fi
 echo $command1
 $command1 #2> /dev/null
 PASS[$i]=${?}
if [ ${PASS[$i]} == 0 ]
then
    echo Num[$i]: OK
    return 0
else
    echo Num[$i]: Failed
    return 1
fi
}
#获取连接adb设备的ID
getdevicelist(){
if [ $isadb == 1 ]
then
adb devices | sed '/List/d' |sed '/^$/d'  > devicesID
else
fastboot devices > devicesID
fi

if [ ! -s devicesID ]
then
    echo "错误：找不到设备"
    exit 1
fi
}
#获得adb设备数量
show(){
Quantity=$(sed -n '$=' devicesID)
echo "------------------------------"
echo "识别到 $Quantity 个设备"
echo "─Devices list:"
#为不同adb设备赋予编号
for i in $(seq $Quantity)
do
    Num[$i]=$(cat devicesID | awk '{print $1}' | sed -n "${i}p")
    echo "  ├─Num[$i]=${Num[$i]}"
done
echo "------------------------------"
}
#cmd adb shell命令可选择一台设备进入
selectdevice(){
    getdevicelist
    show
    read -p "选择进入几号(1/2..)？" selectnum
    if [ $selectnum -gt $Quantity ]
    then
        echo "超出设备数上限,退出..."
        exit 0
    fi
    echo 进入${Num[selectnum]}
    adb -s ${Num[selectnum]} shell
    exit 0
}
#Main
#获取参数
option=$1
case ${option} in
    -h)
	usage
	exit 1;
	;;
    adb)
	echo command：$*
	command=$*
	isadb=1
    if [ "$*" == "adb shell" ]
    then
        selectdevice
    fi
	;;
    fastboot )
	echo command : $*
	command=$*
	isadb=0
	;;
    *)
	    echo "参数错误"
	    usage
	    exit 1;
	;;
esac

#获取连接adb设备的ID
getdevicelist

#获得adb设备数量
show

#查看设备数后确认是否要继续操作
#read -p "是否继续执行？"

#运行命令行
rm -f error.log
for ((i = 1;i <= $Quantity ;i++))
do
{
    cmd || echo Num[$i]=${Num[$i]} Failed >> error.log
}&
done
wait

#打印结果
echo "------------------------------"
echo "      Total : $Quantity"
if [ -f error.log ]
then
    Failed=$(sed -n '$=' error.log)
    echo "    Succeed : $[$Quantity-$Failed]"
    echo "     Failed : $Failed"
    echo "------------------------------"
    echo "Failed list:"
    sort -n error.log
    echo "------------------------------"
    exit 1
else
    echo "    Succeed : $Quantity"
    echo "     Failed : 0"
    echo "------------------------------"
    exit 0
fi
