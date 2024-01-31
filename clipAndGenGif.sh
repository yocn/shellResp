# https://wizyoung.dogcraft.xyz/video2gif-with-high-quality

forceToTime=0
option="clip"
gif_width=480
quality=5
accuracy=1
clipEnd=1
global_ffmpeg_config=" -hide_banner -loglevel panic "
endVideo="end.mp4"
endFlag=1

while getopts ":i:t:q:o:w:elac" optname
do
    case "$optname" in
      "i")
        videoName=$(basename "$OPTARG")
        prefix=${videoName%.*}
        echo "get option -i, value is $OPTARG   videoName:$videoName  prefix:$prefix"
        ;;
      "t")
        echo "get option -t, value is $OPTARG"
        forceToTime=$OPTARG
        ;;
      "q")
        ## 设置生成的gif质量
        echo "get option -q, value is $OPTARG"
        # 0 - 10
        quality=$OPTARG
        ;;
      "o")
        echo "get option -o, value is $OPTARG"
        # clip | delogo | none
        option=$OPTARG 
        ;;
      "w")
        echo "get option -w, value is $OPTARG"
        # gif_width
        gif_width=$OPTARG 
        ;;
      "e")
        ## 添加end.mp4
        echo "get option -e, value is $OPTARG"
        # add end video
        endFlag=1
        ;;
      "a")
        # 是否精确到毫秒，默认关。比如12.512513s的视频，关闭是12，开启是12.512513
        echo "get option -a"
        accuracy=0
        ;;
      "l")
        echo "get option -l"
        global_ffmpeg_config=""
        ;;
      "c")
        echo "get option -c, means no clip 4s end"
        clipEnd=0
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      *)
        echo "Unknown error while processing options"
        ;;
    esac
    #echo "option index is $OPTIND"
done

wh=`ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $videoName`
array=(${wh//,/ })
width=${array[0]}
height=${array[1]}

echo "########width:$width  height:$height##########"
####### 截去最后4s的视频 #########
prefix="clipOut_"$prefix
clipOut="clipOut_"$videoName
if [[ $clipEnd == 1 ]]; then
    duration=`ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $videoName`
    seconds=(${duration//./ })
    second=${seconds[0]}
    millsecond=${seconds[1]}

    echo "减之前的: "$second
    let second-=4
    echo "减之后的: "$second

    if [ $forceToTime -gt 0 ]; then
        second=$forceToTime
        echo "设置了强制裁减时间为$second s"
    fi
    h=`expr $second / 3600`
    m1=`expr $second % 3600`
    m=`expr $m1 / 60`
    s=`expr $second % 60`

    if [[ $accuracy == 0 ]]; then
        time=$h":"$m":"$s
        echo "compat: "$time
        ffmpeg $global_ffmpeg_config -y -i $videoName -c copy -to $time $clipOut
    else  
        time=$h":"$m":"$s"."$millsecond
        echo "full time -> "$time
        ffmpeg $global_ffmpeg_config -y -ss 0 -t $time -i $videoName -c:v libx264 -preset superfast -c:a copy $clipOut
    fi
fi
echo "#######截去最后4s的视频  end ############# "
######## 加片尾 #######
if [[ $endFlag == 0 ]]; then
    clipWithEnd=$clipOut
else
    # 如果片尾尺寸不对，需要修改end的尺寸，end的尺寸是竖屏9：16，所以一般高是不用变的。
    endHeight=$height
    # endWidth=`expr $height * 9 / 16`
    let "endWidth=$height * 9 / 16"
    
    padHeight=$height
    padWidth=$width
    let "padX=($width - $endWidth) / 2"
    padY=0
    echo "endHeight::$endHeight  endWidth: $endWidth padX:$padX  padY:$padY"

    endVideoName=$endWidth"x"$endHeight"x"$padX"x"$padY"_"$endVideo
    if [ ! -e $endVideoName ]; then
      echo "文件不存在"
      echo "scale=$endWidth:$endHeight,pad=$padWidth:$padHeight:$padX:$padY:black"
      ffmpeg $global_ffmpeg_config -y -i $endVideo -vf "scale=$endWidth:$endHeight,pad=$padWidth:$padHeight:$padX:$padY:black" $endVideoName
    fi
    echo "endVideoName::$endVideoName"

    clipWithEnd="WithEnd_"$clipOut
    prefix="WithEnd_"$prefix
    ffmpeg $global_ffmpeg_config -y -i $clipOut -qscale 0 tmp1.mpg
    ffmpeg $global_ffmpeg_config -y -i $endVideoName -qscale 0 tmp2.mpg
    cat tmp1.mpg tmp2.mpg | ffmpeg $global_ffmpeg_config -y -f mpeg -i - -qscale 0 -vcodec mpeg4 $clipWithEnd
   # rm tmp1.mpg
    #rm tmp2.mpg
fi
echo "############加关注片尾视频 end############"
######## 截取视频可用部分 #########
clipStart=$clipWithEnd

echo "w:"$width" h:"$height" option:"$option
if [[ $option == *"clip"* ]]; then
    whOut="clip_"$clipStart
    prefix="clip_"$prefix
    top=80
    height=`expr $height - $top - 90`
    echo "ffmpeg -hide_banner -loglevel panic -y -i $clipStart -vf "crop=$width:$height:0:$top" $whOut"
    ffmpeg $global_ffmpeg_config -y -i $clipStart -vf "crop=$width:$height:0:$top" $whOut
elif [[ $option == *"delogo"* ]]; then
    whOut="delogo_"$clipStart
    prefix="delogo_"$prefix
    delogo2X=`expr $width - 200 - 30`
    delogo2Y=`expr $height - 70 - 20`
    tmp1="tmp_"$whOut
    # delogo1
    # ffplay -i $clipStart -vf delogo=x=20:y=8:w=150:h=60:show=0
    # 480x640 -> delogo=x=1:y=5:w=90:h=32:show=0
    ffmpeg $global_ffmpeg_config -y -i $clipStart -vf delogo=x=1:y=8:w=190:h=70:show=0 $tmp1
    # delogo2
    # ffplay -i $clipStart -vf delogo=x=$delogo2X:y=$delogo2Y:w=200:h=70:show=0
    # 480x640 -> 
    echo "$delogo2X::$delogo2Y  "
    ffmpeg $global_ffmpeg_config -y -i $tmp1 -vf delogo=x=$delogo2X:y=$delogo2Y:w=220:h=80:show=0 $whOut
    rm $tmp1
elif [[ $option == *"none"* ]]; then
    whOut="none_"$clipStart
    prefix="none_"$prefix
    cp $clipStart $whOut
fi
echo "#######视频二次处理end########"
############################### 生成gif ###############################

MAX_FPS=20
MIN_FPS=5

MAX_COLOR=256
MIN_COLOR=10

MAX_BAYER_SCALE=5
MIN_BAYER_SCALE=1

MAX_QUALITY=10
MIN_QUALITY=1

let "fps_param=$MIN_FPS + (($MAX_FPS - $MIN_FPS) * $quality / $MAX_QUALITY)"
let "max_colors_param=$MIN_COLOR + (($MAX_COLOR - $MIN_COLOR) * $quality / $MAX_QUALITY)"
let "bayer_scale_param=$MIN_BAYER_SCALE + (($MAX_BAYER_SCALE - $MIN_BAYER_SCALE) * $quality / $MAX_QUALITY)"

endfix="quality_$quality"
# global filter
fps=$fps_param
scale=$gif_width:-1
interpolation=lanczos
prefix=$prefix"_"$gif_width

# for palettegen
max_colors=$max_colors_param  # up to 256
reserve_transparent=on
stats_mode=full  # chosen from [full, diff, single]

# for paletteuse
dither=bayer  # chosen from [bayer, heckbert, floyd_steinberg, sierra2, sierra2_4a, none]
bayer_scale=$bayer_scale_param  # [0, 5]. only works when dither=bayer. higher means more color banding but less crosshatch pattern and smaller file size
diff_mode=rectangle  # chosen from [rectangle, none]
new=off  # when stats_mode=single and new=on, each frame uses different palette

gifName=$prefix"_"$endfix".gif"

ffmpeg $global_ffmpeg_config -y -i $whOut -vf "drawtext=text='@笑脸研究院':y=h-text_h:x=w-text_w-20*t:fontsize=14:fontcolor=yellow:shadowy=2,fps=$fps,scale=$scale:flags=$interpolation,split[split1][split2];[split1]palettegen=max_colors=$max_colors:reserve_transparent=$reserve_transparent:stats_mode=$stats_mode[pal];[split2][pal]paletteuse=dither=$dither:bayer_scale=$bayer_scale:diff_mode=$diff_mode:new=$new" -y $gifName

echo "quality:"$quality"  fps_param:"$fps_param"  max_colors_param:"$max_colors_param"  bayer_scale_param:"$bayer_scale_param
echo "生成gif  $gifName   end"
