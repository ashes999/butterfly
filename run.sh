haxe compile.hxml

if [ $? -eq 0 ]
then
  mv src/Main.n .
  neko ./Main.n "$@"
  rm Main.n
fi
