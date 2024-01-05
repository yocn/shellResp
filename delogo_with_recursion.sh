#!/bin/bash

# $1 -> src.png
# $2 -> dst.png
function delogo {
    wh=`ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $1`
    echo $wh
    w=0
    h=0
    array=(${wh/,/ })
    for ((index=0; index<${#array[@]}; index++))
    do
       if [ $index -eq 0 ]; then
            w=${array[$index]}
       else
            h=${array[$index]}
       fi
    done
    echo "w:$w h:$h"
    x=$(($w - 100))
    y=$(($h - 20))
    echo "w:$w h:$h"
    delogo="ffmpeg -i $1 -vf delogo=x=$x:y=$y:w=92:h=12:show=0 $2"
    `$delogo`
}

# $1 : src dir
# $2 : dst dir
# $3 : file name
function check() {
    if [ "${1##*.}" != gif ]; then
        echo "$1 不以'.gif'结尾"
        # delogo $1 $2
    else
        echo "$1 以'.gif'结尾"
        cp -rvf "$1" "$2"
    fi
}

# $1: 根目录的绝对路径
# $2: 目标目录的绝对路径
# $3: 当前目录的相对路径
function traverse_directory() {
    root=`pwd`
    currentPath=$1
    srcRootPath=$2
    dstRootPath=$3
    # 根据现在的路径获取相对于srcPath的相对路径，比如： 当前路径:test/srcDir/back1/back  srcPath:test/srcDir  relative:/back1/back
    relative=${currentPath#*$srcRootPath}
    dstPath=$dstRootPath$relative
    dstAbsPath=$root"/"$dstPath
    # echo "当前路径:$currentPath  srcPath:$srcRootPath  relative:$relative  dstPath:$dstPath"

    # 目标文件夹不存在就创建。
    if [ ! -d "$dstAbsPath" ]; then
        mkdir "$dstAbsPath"
    fi

    for item in $currentPath/* 
    do
        filename=$(basename "$item")
        if [ -d "$item" ]; then
            # echo "目录 -> 目录名为$currentPath$item   relativePath::$relativePath"
            traverse_directory $item $srcRootPath $dstRootPath
        else
            # echo "文件 -> 文件名为$currentPath"
            srcFile=$root"/"$currentPath"/"$filename
            dstFile=$root"/"$dstPath"/"$filename
            # echo "src:$srcFile       dst:$dstFile"
            check "$srcFile" "$dstFile"
        fi
    done
}

# $1 -> 源目录
# $2 -> 目标目录
traverse_directory $1 $1 $2
