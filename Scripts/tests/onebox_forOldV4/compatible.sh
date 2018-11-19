#!/bin/bash --login
export LANG=en_US.UTF-8
TEST_BASEPATH='../../../Products/COSV4DemoAppOld/'
TEST_PROJECT='COSDemoApp.xcworkspace'
TEST_SCHEME='COSDemoAppTests'
RESULT_DIRECTORY='default'
# 入参 path 要查找的路径, pattern 模式
SEARCH_FIELS=()
searchFiles() {
  path=$1
  pattern=$2
  files=`find ${path} -name "${pattern}" -maxdepth 100`
  files=`echo ${files[@]} | tr ' ' '\n' | sort -r`
  SEARCH_FIELS=${files[@]}
}

runtest() {
  path=$1
  workspace=$2
  scheme=$3
  podfile=$4
  cp $podfile $path"Podfile"
  echo "path is $path, workspace is $workspace, scheme is $scheme, podfile is $podfile"
  origin=`pwd`
  #  去工作目录
  cd $path
  pod update --no-repo-update
  # 返回原路径
  cd $origin
  xcodebuild \
    -workspace $path$workspace\
    -scheme $scheme\
    -destination 'platform=iOS Simulator,name=iPhone 7,OS=latest' \
    -sdk iphonesimulator \
    test|tee xcodebuild.log| xcpretty --report junit
  # 返回原路径
  version=$5
    mkdir build/reports/$RESULT_DIRECTORY
  mv xcodebuild.log "../../../xcodebuild$version.log"
  cd build/reports
  mv junit.xml "../../../../../iOS-v4.$version.xml"
  cd $origin
}

RESULT_DIRECTORY="test_result_$(date +%y%m%d)"
echo "result directory is $RESULT_DIRECTORY"
mkdir build/reports/$RESULT_DIRECTORY
searchPATH=`pwd`
searchFiles $searchPATH "test.podfile.v*.txt"
files=$SEARCH_FIELS
if [ ${#files[@]}  == 0 ]; then
  echo "没有发现任何可以测试的版本"
else
  for file in ${files[@]}
  do
    echo "使用Podfile脚本进行测试 $file"
    pathLength=${#file}
    version=`echo $file|awk -F 'test.podfile.v' '{print $2}'|awk -F '.txt' '{print $1}'`
    testScheme="$TEST_SCHEME$version"
    echo "test scheme is $testScheme"
    runtest $TEST_BASEPATH $TEST_PROJECT $testScheme $file $version
  done

fi
