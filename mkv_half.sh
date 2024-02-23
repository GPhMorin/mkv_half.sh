#!/bin/bash

file_pattern="$@"

if [ ! $file_pattern ]; then
  file_pattern="DSC*.avi DSC*.AVI"
fi

for file in $(ls -f $file_pattern 2> /dev/null)
do
  echo Checking $file
  if [[ "$(file $file)" == *"video: Motion JPEG"* ]]; then
    echo Processing $file
    filenamebase=${file%.*}
    echo Create right video: "$filenamebase"_r.MKV
    ffmpeg -loglevel error -i $file -f matroska -pix_fmt yuv420p -crf 2 -map 0:v:1 -map 0:a:0 -c:a copy "$filenamebase"_r.MKV
    echo Create left video: "$filenamebase"_l.MKV
    ffmpeg -loglevel error -i $file -f matroska -pix_fmt yuv420p -crf 2 -map 0:v:0 -map 0:a:0 -c:a copy "$filenamebase"_l.MKV
    echo Join left/right videos to a half SBS video: "$filenamebase"_HSBS.MKV
    ffmpeg -loglevel error -i "$filenamebase"_l.MKV -i "$filenamebase"_r.MKV \
	   -filter_complex "pad=in_w*2:in_h, overlay=main_w/2:0, scale=in_w/2:in_h" \
	   -f matroska -crf 2 -aspect 32:9 -metadata:s:v stereo_mode=left_right -c:a copy -map 0:a:0 "$filenamebase"_HSBS.MKV
  fi
done
