haxe compile.hxml

if [ $? -eq 0 ]
then
  neko ./Main.n "$@"
  rm Main.n
fi
