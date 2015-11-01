#!/bin/bash
image_path=/Users/lijunjie/Desktop/demo-xiao6say.png

expect_width=700.0
expect_height=440.0

width=`identify -format "%[fx:w]\n" ${image_path}`
height=`identify -format "%[fx:h]\n" ${image_path}`

width_percent=$(echo "${expect_width}*100/${width}+1" | bc)
height_percent=$(echo "${expect_height}*100/${height}+1" | bc)
resize_percent=$((width_percent > height_percent ? width_percent : height_percent))
echo "${width_percent},${height_percent},${resize_percent}"

convert -sample ${resize_percent}%x${resize_percent}%  ${image_path} ${image_path}@resize.png
convert ${image_path}@resize.png -crop ${expect_width}x${expect_height}+0+0 ${image_path}@crop.png

