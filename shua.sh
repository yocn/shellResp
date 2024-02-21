function use(){
    ts=0.05
    # 打开钻石商店
    adb shell input tap 996 2013
    sleep $ts
    # 购买礼盒
    adb shell input tap 586 1616
    # 购买礼盒
    adb shell input tap 586 1616
    # 购买礼盒
    adb shell input tap 586 1616
    # 购买礼盒
    adb shell input tap 586 1616
    # 购买礼盒
    adb shell input tap 586 1616
    # 购买礼盒
    adb shell input tap 586 1616
    sleep $ts
    # 关掉商店
    adb shell input tap 956 431
    sleep $ts
    # 使用第1个礼盒
    adb shell input tap 485 164
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts
    # 使用第2个礼盒
    adb shell input tap 585 164
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts
    # 使用第3个礼盒
    adb shell input tap 680 164
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts
    # 使用第4个礼盒
    adb shell input tap 786 164
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts
    # 使用第5个礼盒
    adb shell input tap 908 169
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts
    # 使用第6个礼盒
    adb shell input tap 1008 169
    sleep $ts
    # 开礼盒
    adb shell input tap 432 1535
    sleep $ts 
}

function sell() {
    ts=0.05
    # 打开背包
    adb shell input tap 830 2013
    sleep $ts
    # 批量出售
    adb shell input tap 466 1859
    sleep $ts
    # 出售蓝装
    adb shell input tap 466 1474
    sleep $ts
    # 批量出售
    adb shell input tap 466 1859
    sleep $ts
    # 出售紫装
    adb shell input tap 466 1336
    sleep $ts
    # 批量出售
    adb shell input tap 466 1859
    sleep $ts
    # 出售橙装
    # adb shell input tap 466 1219
    # sleep $ts
    # 
    adb shell input tap 195 1849
    sleep $ts
    # 关掉
    adb shell input tap 1009 314
    sleep $ts
}

while true; do 
    use
    sell
done