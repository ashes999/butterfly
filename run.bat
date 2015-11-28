@echo off
haxe -lib markdown -main Main -neko Main.n
neko ./Main.n %*
del Main.n
