@echo off
haxe compile.hxml
neko build\Main.n %*
del build\Main.n