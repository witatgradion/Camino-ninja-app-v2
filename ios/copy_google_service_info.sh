#!/bin/sh

# Get a reference to the destination location for the GoogleService-Info.plist
# This is the default location where Firebase init code expects to find GoogleServices-Info.plist file.
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app
# We have named our Build Configurations as Debug-dev, Debug-prod etc.
# Here, dev and prod are the scheme names. This kind of naming is required by Flutter for flavors to work.
# We are using the $CONFIGURATION variable available in the XCode build environment to get the build configuration.
echo "Copying config files"
echo ${CONFIGURATION}
if [ "${CONFIGURATION}" == "Debug-production" ] || [ "${CONFIGURATION}" == "Release-production" ] || [ "${CONFIGURATION}" == "Profile-production" ]; then
cp "${PROJECT_DIR}/config/prod/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
echo "Production plist copied"
elif [ "${CONFIGURATION}" == "Debug-development" ] || [ "${CONFIGURATION}" == "Release-development" ] || [ "${CONFIGURATION}" == "Profile-development" ]; then
cp "${PROJECT_DIR}/config/dev/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
echo "Development plist copied"
elif [ "${CONFIGURATION}" == "Debug-staging" ] || [ "${CONFIGURATION}" == "Release-staging" ] || [ "${CONFIGURATION}" == "Profile-staging" ]; then
cp "${PROJECT_DIR}/config/stg/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
echo "Staging plist copied"
else
echo "Copied nothing"
fi

# Ensure the GoogleService-Info.plist file exists in the destination
if [ -e "${PROJECT_DIR}/Runner/GoogleService-Info.plist" ]; then
    echo "Successfully copied GoogleService-Info.plist"
else
    echo "Failed to copy GoogleService-Info.plist"
    exit 1
fi