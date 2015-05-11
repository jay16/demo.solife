#!/bin/bash
# cd app-path/tmp then doing
#
# usage:
# 	generate_isearch_file 12 "title" "body"
#
id="$1"
poetry_title="$2"
poetry_body="$3"

test -z ${id} && echo "Need Params: Please pass a integer as id." && exit
test -z ${poetry_title} && echo "Need Params: Please pass a string as poetry title." && exit
test -z ${poetry_body} && echo "Need Params: Please pass a string as poetry body." && exit


font_url="http://solife-code.u.qiniudn.com/STXINGKA.ttf"
font_name=${font_url##*/}

test -f ${font_name} || wget ${font_url}
test -d ${id}/images || mkdir -p ${id}/images

convert -background white -fill blue -font ${font_name} -pointsize 72 label:"${poetry_title}-[${id}]" ${id}/images/poetry_title.gif
convert -background white -fill blue -font ${font_name} -pointsize 72 label:"${poetry_body}" ${id}/images/poetry_body.gif

echo "<html>
		<body>
			<img src='./images/poetry_title.gif'>
			<img src='./images/poetry_body.gif'>
		</body>
	  </html>" > ${id}/index.html

test -f ${id}.zip && rm ${id}.zip

zip -r ${id}.zip ${id}/