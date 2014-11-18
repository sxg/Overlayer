#!/bin/sh
#Update build number with number of git commits if in release mode
if [ ${CONFIGURATION} == "Release" ]; then
buildNumber=$(git rev-list HEAD | wc -l | tr -d ' ')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
fi;
