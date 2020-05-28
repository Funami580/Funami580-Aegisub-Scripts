#!/bin/bash

filename=$(basename "$1")
directory=$(dirname "$1")
subname="Aegisub"

cd "$HOME"
mkdir -p .fonts

if [ "$2" = false ] ; then
  cd "${HOME}/.fonts/"
  rm -f Aegisub*
fi

cd "$directory"

while IFS='' read -r line
do
  if [[ "$line" =~ "Attachment ID" ]]
  then
    id=$(echo ${line} | egrep -o '[0-9]*' | head -1)
    name=$(echo ${line} | awk -F, '{ print $NF }' | egrep -o "'.*?'" | tr -d \')
    
    if [ "$2" = true ] ; then
      mkvextract attachments "$filename" ${id}:"${HOME}/.fonts/${name}"
    else
      filebase=$(basename "$name")
      ext="${filebase##*.}"
      mkvextract attachments "$filename" ${id}:"${HOME}/.fonts/${subname}$(printf %02d ${id}).${ext}"
    fi
  fi
done < <(mkvmerge --ui-language en_US --identify "$filename")
