#!/bin/bash

project_dirname=/Users/lijunjie/Code/work/demo-solife
backup_extname=".bak.libray"
libraies_with_version=(bootstrap.320.min.js jquery-2.1.1.min.js)
libraies_without_version=(bootstrap.min.js jquery.min.js)

for index in {0..1}
do
  libray_with_version=${libraies_with_version[index]}
  libray_without_version=${libraies_without_version[index]}
  echo "${libray_with_version} => ${libray_without_version}"

  grep -lnr ${libray_with_version} --include=*.{rb,haml} ${project_dirname} | xargs sed -i ${backup_extname} "s/${libray_with_version}/${libray_without_version}/g"
done

find ${project_dirname} -type f -name "*${backup_extname}" -exec rm {} \;

