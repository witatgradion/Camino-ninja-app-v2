#!/bin/bash

# Exit if any command fails
set -e

# Ensure the output directory exists
mkdir -p lib/src/proto

# Add pub cache bin to PATH if it exists
if [ -d "$HOME/.pub-cache/bin" ]; then
  export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# Find the protoc-gen-dart plugin
PROTOC_PLUGIN_PATH=$(which protoc-gen-dart)
if [ -z "$PROTOC_PLUGIN_PATH" ]; then
  echo "Error: protoc-gen-dart not found. Make sure it's installed and in your PATH."
  echo "You can install it with: dart pub global activate protoc_plugin"
  echo ""
  echo "Also make sure to add the pub cache bin directory to your PATH:"
  echo "export PATH=\"\$PATH\":\"\$HOME/.pub-cache/bin\""
  exit 1
fi

# Run protoc for each proto file
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/common.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/albergue.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/latest_updated.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/albergue_user_ratings.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/albergue_user_images.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/alt_route_points.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/route.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/route_points.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/albergue_user_reviews.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/city.proto
protoc --dart_out=lib/src/proto \
  --proto_path=proto \
  proto/city_pairs.proto


echo "Proto files generated successfully!" 