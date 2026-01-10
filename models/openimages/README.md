This folder is for optional Open Images object-detection models.

Recommended (CPU-friendly) rabbit-capable detector:
- TensorFlow Object Detection API (TF1) model: `ssd_mobilenet_v2_oid_v4_2018_12_12`
- Download:
  - http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_oid_v4_2018_12_12.tar.gz

After extracting, set these paths in `config.yaml`:
- `cv.objs_detector: tf_openimages`
- `cv.objs_target_class_id: 260`  # Rabbit
- `cv.objs_tf_model_path: models/openimages/ssd_mobilenet_v2_oid_v4_2018_12_12/frozen_inference_graph.pb`
- `cv.objs_tf_config_path: models/openimages/ssd_mobilenet_v2_oid_v4_2018_12_12/graph.pbtxt` (optional but recommended)

Note: model files are large and are not committed to git.
