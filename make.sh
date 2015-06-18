#!/bin/bash

# get directory of script
DIR="$( cd "$( dirname "$0" )" && pwd )"

coffee --compile --output $DIR/build/ $DIR/coffee/

jFiles=$(find build -name '*.js')

uglifyjs $jFiles -o $DIR/www/js/wwww.min.js -mc

lessc --no-color -x less/wwww.less www/css/wwww.min.css
