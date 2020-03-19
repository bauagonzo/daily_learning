#/usr/bin/env bash
TMPDIR=${TMPDIR:-/tmp}
cd $TMPDIR
curl -LOk https://github.com/tldr-pages/tldr/archive/master.zip
unzip master.zip
mkdir -p cheats
cp -rf tldr-master/pages/linux/* cheats
cp -rf tldr-master/pages/common/* cheats
cd cheats
rename .md '' *.md
cd ..
cp -rf cheats/* ~/.cheat
rm -rf master.zip tldr-master cheats

