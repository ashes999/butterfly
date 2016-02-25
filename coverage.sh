#!/bin/sh
rm coverage.txt
haxelib run munit test -coverage >coverage.txt
echo coverage generated to coverage.txt
