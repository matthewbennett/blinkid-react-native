#!/bin/bash

blink_id_plugin_path=`pwd`/BlinkID

# remove any existing code
rm -rf BlinkIDReactNative

# create a sample application
react-native init --version="0.58.5" BlinkIDReactNative

# enter into demo project folder
pushd BlinkIDReactNative

if true; then
  # download npm package
  echo "Downloading blinkid-react-native module"
  npm i --save blinkid-react-native

  npm install
else
  echo "Using blinkid-react-native from this repo instead from NPM"
  # use directly source code from this repo instead of npm package
  # from RN 0.57 symlink does not work any more
  npm pack $blink_id_plugin_path
  npm i --save blinkid-react-native-4.8.0.tgz
  npm install
  #pushd node_modules
    #ln -s $blink_id_plugin_path blinkid-react-native
  #popd
fi

# link package with project
echo "Linking blinkid-react-native module with project"
react-native link blinkid-react-native

# enter into android project folder
pushd android

# patch the build.gradle
perl -i~ -pe "s/maven \{/maven \{ url 'https:\\/\\/maven.microblink.com' }\n        maven {/" build.gradle

popd

# enter into ios project folder
pushd ios

# initialize Podfile
echo "Initializing and installing Podfile"
pod init

# remove Podfile
rm -f Podfile

# replace Podfile with new Podfile
cat > Podfile << EOF
platform :ios, '8.0'

target 'BlinkIDReactNative' do
  pod 'PPBlinkID', '~> 4.8.0'
end
EOF

# install pod
pod install

if false; then
  echo "Replace pod with custom dev version of BlinkID framework"
  # replace pod with custom dev version of BlinkID framework
  pushd Pods/PPBlinkID
  rm -rf Microblink.bundle
  rm -rf Microblink.framework

  cp -r ~/Downloads/blinkid-ios/Microblink.bundle ./
  cp -r ~/Downloads/blinkid-ios/Microblink.framework ./
  popd
fi

# go to react native root project
popd

# remove index.js
rm -f index.js

# remove index.ios.js
rm -f index.ios.js

# remove index.android.js
rm -f index.android.js

cp ../demoApp/index.js ./

# use the same index.js file for Android and iOS
cp index.js index.ios.js
cp index.js index.android.js

echo "Go to React Native project folder: cd BlinkIDReactNative"
echo "To run on Android execute: react-native run-android"
echo "To run on iOS: go to BlinkIDReactNative/ios and open BlinkIDReactNative.xcworkspace; set your development team and add Privacy - Camera Usage Description key to Your info.plist file and press run"
