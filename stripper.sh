#!/bin/sh

TEMP_FOLDER="/tmp"
TEMP_CHARTS_FOLDER="$TEMP_FOLDER/stripcharts"
TEMP_CATALOG_FOLDER="$TEMP_FOLDER/catalog"

initial_setup() {

  if [ -d "$TEMP_CHARTS_FOLDER" ]; then
    cd $TEMP_CHARTS_FOLDER
    git clean -f -x
    git fetch origin main
    git reset --hard origin/main
    git pull
  else
    git clone $STRIP_REPO $TEMP_CHARTS_FOLDER --depth 1
  fi

  if [ -d "$TEMP_CATALOG_FOLDER" ]; then
    cd $TEMP_CATALOG_FOLDER
    git clean -f -x
    git fetch origin main
    git reset --hard origin/main
    git pull
  else
    git clone -b main --single-branch $CATALOG_REPO $TEMP_CATALOG_FOLDER --depth 1
  fi

  cd $TEMP_FOLDER
}


cleanup_strip_charts() {
  cd $TEMP_CHARTS_FOLDER
  rm -rf enterprise
  rm -rf dependency
  rm -rf stable
  rm -rf operators
  rm -rf premium
  rm -rf system
  
  mkdir stable
  mkdir premium
  mkdir dependency
  mkdir enterprise
  mkdir operators
  mkdir system
  

  cd $TEMP_FOLDER
}

copy_charts() {
  echo "Copying charts for $1: $2"
  if [ "$2" == "all" ]; then
    cp -r $TEMP_CATALOG_FOLDER/$1/* $TEMP_CHARTS_FOLDER/$1
  elif [ -n "$2" ]; then
    cd $TEMP_CATALOG_FOLDER/$1
    echo "Copying charts for $1: $2"
    ls -1 . | grep -E "^($2)\$" | xargs cp -r -t $TEMP_CHARTS_FOLDER/$1
    cd ..
  fi
}

parse_mapping() {
  if [ -n "$2" ]; then
    APPS=$(echo $2 | tr '|' ' ')
    MAPPING=""

    for i in $APPS
    do
      MAPPING="$MAPPING \"$i\": .$1.\"$i\","
    done

    echo ${MAPPING}
  fi
}

copy_catalog_file() {
  cp $TEMP_CATALOG_FOLDER/catalog.json $TEMP_CHARTS_FOLDER/catalog.json
  
  cd $TEMP_CHARTS_FOLDER
  ls -al .

  local STABLE_MAPPING=$(parse_mapping stable $STRIP_STABLE )
  
  local PREMIUM_MAPPING=$(parse_mapping premium $STRIP_PREMIUM )
  
  local ENTERPRISE_MAPPING=$(parse_mapping enterprise $STRIP_ENTERPRISE )
  
  local DEPENDENCY_MAPPING=$(parse_mapping dependency $STRIP_DEPENDENCY )
  local OPERATORS_MAPPING=$(parse_mapping operators $STRIP_OPERATORS )
  
  local SYSTEM_MAPPING=$(parse_mapping system $STRIP_SYSTEM )

  jq "{charts, test, operators: { $OPERATORS_MAPPING}, dependency: { $DEPENDENCY_MAPPING }, stable: { $STABLE_MAPPING },  premium: { $PREMIUM_MAPPING }, enterprise: { $ENTERPRISE_MAPPING }, system: { $SYSTEM_MAPPING }}" catalog.json > catalog.json.tmp
  mv catalog.json.tmp catalog.json
}

commit_changes() {
  cd $TEMP_CHARTS_FOLDER
  git add .
  git config --global user.email "${GITHUB_EMAIL:=strip@charts.com}"
  git config --global user.name "${GITHUB_NAME:=StripCharts}"
  git commit -a -m "update"
  git push -f
}

initial_setup
cleanup_strip_charts
copy_charts stable $STRIP_STABLE
copy_charts premium $STRIP_PREMIUM
copy_charts dependency $STRIP_DEPENDENCY
copy_charts enterprise $STRIP_ENTERPRISE
copy_charts operators $STRIP_OPERATORS
copy_charts system $STRIP_SYSTEM
copy_catalog_file
commit_changes
