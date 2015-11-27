haxe -main Main -neko Main.n

if [ $? -eq 0 ]
then
  neko ./Main.n "$@"
  rm Main.n
fi
