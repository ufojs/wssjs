#! /bin/bash

cp lib/wss.bundle.js lib/wss.bundle.js.old

LN=`grep -n "if (Buffer._useTypedArrays && typeof subject.byteLength === 'number') {" lib/wss.bundle.js | awk 'BEGIN { FS = ":" } ; { print $1 }'`
ALL=`wc -l lib/wss.bundle.js.old | awk '{ print $1 }'`

head -n $(( $LN - 1 )) lib/wss.bundle.js.old > lib/wss.bundle.js
echo "if (Buffer._useTypedArrays && typeof subject.byteLength === 'number') {" >> lib/wss.bundle.js
tail -n $(( $ALL - $LN )) lib/wss.bundle.js.old >> lib/wss.bundle.js
