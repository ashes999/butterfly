@echo off
haxe compile.hxml
neko ./Main.n %*
del Main.n
