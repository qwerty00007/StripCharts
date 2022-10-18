#!/bin/sh

rm -rf /tmp/stripdance
git clone $STRIP_REPO /tmp/stripdance
cd /tmp/stripdance

rm -rf sexy
rm -rf stable
rm -rf incubator
mkdir stable
mkdir incubator

curl -L -o main.zip http://192.168.100.230:10037/hedegang/catalog/archive/main.zip

unzip main.zip
rm -f main.zip
cd catalog

ls -la .

rm -rf .github

cd stable
ls -1 . |
grep -E "^($STRIP_STABLE)\$" |
xargs cp -r -t ../../stable/

cd ../incubator
ls -1 . |
grep -E "^($STRIP_INCUBATOR)\$" |
xargs cp -r -t ../../incubator/

cd ..

rm -rf dependency enterprise incubator stable

for x in ./* ./.[!.]* ./..?*; do
  if [ -e "$x" ]; then mv -- "$x" ../; fi
done

cd ..
rm -rf catalog

git add .
git config --global user.email "1165505953@qq.com"
git config --global user.name "hedegang"
git commit -a --amend -m "update" || git commit -a -m "update"
git push -f

cd /tmp
rm -rf /tmp/stripdance