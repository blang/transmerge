#!/bin/sh
DIR=`dirname $1`
FILE=`basename $1`
echo $DIR
cd "$DIR"
git blame -t --encoding=uft-8 --line-porcelain $FILE | sed -n 's/author-time //p'