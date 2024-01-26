
set -e
# https://wizyoung.dogcraft.xyz/video2gif-with-high-quality

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

tmpFile="tmp.gif"
ffmpeg -i $1 -vf "drawtext=text='@笑脸研究院':y=h-text_h:x=w-text_w-20*t:fontsize=14:fontcolor=yellow:shadowy=2,fps=$fps,scale=$scale:flags=$interpolation,split[split1][split2];[split1]palettegen=max_colors=$max_colors:reserve_transparent=$reserve_transparent:stats_mode=$stats_mode[pal];[split2][pal]paletteuse=dither=$dither:bayer_scale=$bayer_scale:diff_mode=$diff_mode:new=$new" -y $2

# ffmpeg -i $2 -vf "drawtext=text='@笑脸研究院':y=h-text_h:x=w-text_w-20*t:fontsize=14:fontcolor=yellow:shadowy=2" $2