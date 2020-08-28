#!/bin/bash

TAGET_DIR="./"
TARGET_STR="target"
for f in `ls $TAGET_DIR`;do
    if [[ $f =~ ^"$TARGET_STR$1".* ]]
    then
        `rm $f`
    fi
done

if [[ -d "./fileDir/$1tempDir" ]]
then
    `rm -rf "./fileDir/$1tempDir"`
fi


