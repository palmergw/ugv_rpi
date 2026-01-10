#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="$REPO_ROOT/models/openimages"
MODEL_NAME="ssd_mobilenet_v2_oid_v4_2018_12_12"
URL="http://download.tensorflow.org/models/object_detection/${MODEL_NAME}.tar.gz"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

echo "Downloading $URL"
curl -L "$URL" -o "${MODEL_NAME}.tar.gz"

echo "Extracting into $DEST_DIR/$MODEL_NAME"
mkdir -p "$MODEL_NAME"
tar -xzf "${MODEL_NAME}.tar.gz" -C "$MODEL_NAME"

# Optional: place a pbtxt path expected by config.
# Some OpenCV builds work without a pbtxt; for best compatibility you can generate one externally.
# We create an empty placeholder if none exists.
if [[ ! -f "$MODEL_NAME/graph.pbtxt" ]]; then
  echo "" > "$MODEL_NAME/graph.pbtxt"
fi

echo "Done. Configure config.yaml:"
echo "  cv.objs_detector: tf_openimages"
echo "  cv.objs_target_class_id: 260"
echo "  cv.objs_tf_model_path: models/openimages/$MODEL_NAME/frozen_inference_graph.pb"
echo "  cv.objs_tf_config_path: models/openimages/$MODEL_NAME/graph.pbtxt"
