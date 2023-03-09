#!/usr/bin/env sh
./tinygo build -target wasm -o /tmp/tinygo.wasm "$1"
wasm2wat /tmp/tinygo.wasm > /tmp/preprocess.wat
raku effects.pl </tmp/preprocess.wat
