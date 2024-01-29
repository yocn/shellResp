# https://wizyoung.dogcraft.xyz/video2gif-with-high-quality

forceToTime=0
option="clip"
quality=5

# videoName=$1
# prefix=${videoName%.*}
while getopts ":i:t:q:o:" optname
do
    case "$optname" in
      "i")
        videoName=$OPTARG
        prefix=${videoName%.*}
        echo "get option -i,value is $OPTARG  prefix:$prefix"
        ;;
      "t")
        echo "get option -t ,value is $OPTARG"
        forceToTime=$OPTARG
        ;;
      "q")
        echo "get option -q,value is $OPTARG"
        # 0 - 10
        quality=$OPTARG
        ;;
      "o")
        echo "get option -o,value is $OPTARG"
        # clip | delogo
        option=$OPTARG 
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
############################### 截去最后4s的视频 ###############################
duration=`ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $videoName`
second=${duration%%.*}
echo $second
let second-=4
echo $second
if [ $forceToTime -gt 0 ]; then
    second=$forceToTime
    echo "设置了强制裁减时间为$second s"
fi
h=`expr $second / 3600`
m1=`expr $second % 3600`
m=`expr $m1 / 60`
s=`expr $second % 60`
time=$h":"$m":"$s
echo $time

clipOut=$prefix"_clipOut.mp4"
ffmpeg -hide_banner -y -i $videoName -c copy -to $time $clipOut

echo "截去最后4s的视频 end"
############################### 截取视频可用部分 ###############################
wh=`ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $videoName`
echo $wh

array=(${wh//,/ })
w=${array[0]}
h=${array[1]}

whOut=$prefix"whOut.mp4"
echo "w:"$w" h:"$h" option:"$option
if [[ $option == *"clip"* ]]; then
    prefix=$prefix"_clip"
    top=80
    height=`expr $h - $top - 90`
    echo "ffmpeg -hide_banner -y -i $clipOut -vf "crop=$w:$height:0:$top" $whOut"
    ffmpeg -hide_banner -y -i $clipOut -vf "crop=$w:$height:0:$top" $whOut
elif [[ $option == *"delogo"* ]]; then
    prefix=$prefix"_delogo"
    delogo2X=`expr $w - 200 - 30`
    delogo2Y=`expr $h - 70 - 20`
    tmp1=$prefix"whOut1.mp4"
    # delogo1
    # ffplay -i $clipOut -vf delogo=x=20:y=8:w=150:h=60:show=0
    # 480x640 -> delogo=x=1:y=5:w=90:h=32:show=0
    ffmpeg -hide_banner -y -i $clipOut -vf delogo=x=1:y=8:w=190:h=70:show=0 $tmp1
    # delogo2
    # ffplay -i $clipOut -vf delogo=x=$delogo2X:y=$delogo2Y:w=200:h=70:show=0
    # 480x640 -> 
    ffmpeg -hide_banner -y -i $tmp1 -vf delogo=x=$delogo2X:y=$delogo2Y:w=220:h=80:show=0 $whOut
fi
echo "视频二次处理end"
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
echo "quality:"$quality"  fps_param:"$fps"  max_colors_param:"$color"  bayer_scale_param:"$scale

endfix="quality_$quality"
# global filter
fps=$fps_param
scale=480:-1
interpolation=lanczos

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

ffmpeg -hide_banner -y -i $whOut -vf "drawtext=text='@笑脸研究院':y=h-text_h:x=w-text_w-20*t:fontsize=14:fontcolor=yellow:shadowy=2,fps=$fps,scale=$scale:flags=$interpolation,split[split1][split2];[split1]palettegen=max_colors=$max_colors:reserve_transparent=$reserve_transparent:stats_mode=$stats_mode[pal];[split2][pal]paletteuse=dither=$dither:bayer_scale=$bayer_scale:diff_mode=$diff_mode:new=$new" -y $gifName

echo "quality:"$quality"  fps_param:"$fps"  max_colors_param:"$color"  bayer_scale_param:"$scale
echo "生成gif end"
