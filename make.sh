#!/bin/bash

# get directory of script
DIR="$( cd "$( dirname "$0" )" && pwd )"

coffee --compile --output $DIR/build/ $DIR/coffee/

jFiles=$(find build -name '*.js')

VERMAJOR=0
VERMINOR=1
VERSION=`date +%Y.%m.%d.%H.%M`

echo "@version: 'built $VERMAJOR.$VERMINOR.$VERSION';" > "$DIR/less/version.less"

uglifyjs $jFiles -o $DIR/www/js/wwww.min.js -mc

lessc --no-color -x less/wwww.less www/css/wwww.min.css

mkdir -p www/data
cp data/question.csv www/data/question.csv
