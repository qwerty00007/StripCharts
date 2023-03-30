#!/bin/sh

rm -rf /tmp/stripcharts
git clone $STRIP_REPO /tmp/stripcharts
cd /tmp/stripcharts

rm -rf enterprise
rm -rf dependency
rm -rf stable
rm -rf incubator
mkdir stable
mkdir incubator
mkdir dependency
mkdir enterprise

cd ../

curl -L -o main.zip https://github.com/truecharts/catalog/archive/refs/heads/main.zip

unzip main.zip
rm -f main.zip
cd catalog-main

ls -la .

rm -rf .github

if [ -n "$STRIP_STABLE" ]; then
  cd stable
  ls -1 . | grep -E "^($STRIP_STABLE)\$" | xargs cp -r -t ../../stripcharts/stable
  cd ..
fi

if [ -n "$STRIP_INCUBATOR" ]; then
  cd incubator
  ls -1 . | grep -E "^($STRIP_INCUBATOR)\$" | xargs cp -r -t ../../stripcharts/incubator/
  cd ..
fi

if [ -n "$STRIP_DEPENDENCY" ]; then
  cd dependency
  ls -1 . | grep -E "^($STRIP_DEPENDENCY)\$" | xargs cp -r -t ../../stripcharts/dependency/
  cd ..
fi

if [ -n "$STRIP_ENTERPRISE" ]; then
  cd enterprise
  ls -1 . | grep -E "^($STRIP_ENTERPRISE)\$" | xargs cp -r -t ../../stripcharts/enterprise/
  cd ..
fi

cp catalog.json ../stripcharts/catalog.json

cd ../stripcharts

STABLE_APPS=(`echo $STRIP_STABLE | tr '|' ' '`)
STABLE_MAPPING=""

for i in "${STABLE_APPS[@]}"
do
  STABLE_MAPPING="$STABLE_MAPPING $i: .stable.$i,"
done

INCUBATOR_APPS=(`echo $STRIP_INCUBATOR | tr '|' ' '`)
INCUBATOR_MAPPING=""

for i in "${INCUBATOR_APPS[@]}"
do
  INCUBATOR_MAPPING="$INCUBATOR_MAPPING $i: .incubator.$i,"
done

DEPENDENCY_APPS=(`echo $STRIP_DEPENDENCY | tr '|' ' '`)
DEPENDENCY_MAPPING=""

for i in "${DEPENDENCY_APPS[@]}"
do
  DEPENDENCY_MAPPING="$DEPENDENCY_MAPPING $i: .dependency.$i,"
done

ENTERPRISE_APPS=(`echo $STRIP_ENTERPRISE | tr '|' ' '`)
ENTERPRISE_MAPPING=""
for i in "${ENTERPRISE_APPS[@]}"
do
  ENTERPRISE_MAPPING="$ENTERPRISE_MAPPING $i: .enterprise.$i,"
done

jq "{charts, test, stable: { $STABLE_MAPPING }, incubator: { $INCUBATOR_MAPPING }, dependency: { $DEPENDENCY_MAPPING }, enterprise: { $ENTERPRISE_MAPPING }}" catalog.json > catalog.json.tmp
mv catalog.json.tmp catalog.json

cd ..
rm -rf catalog-main

cd stripcharts

git add .
git config --global user.email "${GITHUB_EMAIL:=strip@charts.com}"
git config --global user.name "${GITHUB_NAME:=StripCharts}"
git commit -a -m "update"
git push -f

cd ../../
rm -rf /tmp/stripcharts
