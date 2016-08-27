#!/bin/bash
link="$1"
delete_dirs="$2"
project_dir="/home/abdalla/projects/fixarabicencoding"
function dir_name (){
   echo $( echo "$link" | sed -e 's/\//_/g')
}
fullpath="$project_dir/$(dir_name)"
function get_download_link (){
  link_contant=$(curl -s $link )
  session=$(echo "$link_contant" | grep -o  "\?mac=.*\"" | awk '{print $1}')
  session="${session/\"/}"
  echo "https://subscene.com/subtitle/download$session"
}

function make_subtitle_dir (){
  if [ -d "$project_dir" ]; then
      cd $project_dir
      if [ ! -d "$fullpath" ]; then
         mkdir $fullpath
         echo $fullpath
      else
        echo "this subtitle directory already exist $fullpath"
        exit 1
      fi
  else
    echo "fix encoding directory not exist $project_dir"
    exit 1
  fi
}
function prep_subtitle_file (){
  dir=$(make_subtitle_dir)
  if [ -d "$dir" ]; then
      cd  $dir && curl -o subtitle.zip $(get_download_link) && unzip subtitle.zip
  else
     echo $dir
     exit 1
  fi
}

function fix_encoding (){
   prep_subtitle_file
   cd $project_dir ; ruby subtitle_fixer.rb $fullpath
}
function delete_old_dir (){
   find $project_dir -type d -iname "https*" | xargs -d "\n"  rm -r
}
if [ "$link" == "-d" ] && [ -z "$delete_dirs" ]; then
  delete_old_dir
  exit 0
elif [ "$link" != "-d" ]; then
  fix_encoding
  exit 0
elif [ "$link" != "-d" ] && [ "$delete_dirs" == "-d" ]; then
  delete_old_dir
  fix_encoding
  exit 0
else
  echo "please correct your command , subtitlefixer link -d"
  exit 1
fi
