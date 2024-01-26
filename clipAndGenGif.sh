
# https://wizyoung.dogcraft.xyz/video2gif-with-high-quality

# $1: 需要裁剪最后4s的视频
# $2: 需要输出的gif
############################### 截去最后4s的视频 ###############################
duration=`ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $1`
second=${duration%%.*}
echo $second
let second-=4
echo $second
h=`expr $second / 3600`
m1=`expr $second % 3600`
m=`expr $m1 / 60`
s=`expr $second % 60`
time=$h":"$m":"$s
echo $time

clipOut="safdafsasd.mp4"
ffmpeg -y -i $1 -c copy -to $time $clipOut

echo "截去最后4s的视频 end"
############################### 把画面上下的皮皮虾logo截掉 ###############################
wh=`ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $1`
echo $wh

array=(${wh//,/ })
w=${array[0]}
h=${array[1]}
top=80
height=`expr $h - $top - 90`

echo $w" "$h" "$top" "$height
whOut="whOut.mp4"
echo "ffmpeg -y -i $clipOut -vf "crop=$w:$height:0:$top" $whOut"
ffmpeg -y -i $clipOut -vf "crop=$w:$height:0:$top" $whOut

echo "把画面上下的皮皮虾logo截掉 end"
############################### 生成gif ###############################
# global filter
fps=10
scale=480:-1
interpolation=lanczos

# for palettegen
max_colors=200  # up to 256
reserve_transparent=on
stats_mode=full  # chosen from [full, diff, single]

# for paletteuse
dither=bayer  # chosen from [bayer, heckbert, floyd_steinberg, sierra2, sierra2_4a, none]
bayer_scale=3  # [0, 5]. only works when dither=bayer. higher means more color banding but less crosshatch pattern and smaller file size
diff_mode=rectangle  # chosen from [rectangle, none]
new=off  # when stats_mode=single and new=on, each frame uses different palette

ffmpeg -y -i $whOut -vf "drawtext=text='@笑脸研究院':y=h-text_h:x=w-text_w-20*t:fontsize=14:fontcolor=yellow:shadowy=2,fps=$fps,scale=$scale:flags=$interpolation,split[split1][split2];[split1]palettegen=max_colors=$max_colors:reserve_transparent=$reserve_transparent:stats_mode=$stats_mode[pal];[split2][pal]paletteuse=dither=$dither:bayer_scale=$bayer_scale:diff_mode=$diff_mode:new=$new" -y $2

echo "生成gif end"