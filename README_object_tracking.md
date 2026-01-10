# Object Tracking (Rabbit-ready)

This repo’s **OBJECTS** CV mode can now be configured to:
- detect objects,
- pick a **target class id**, and
- keep that target centered by driving the gimbal (when motion is **UNLOCKED**).

The target class id can be changed from the web UI at runtime.

## Quick start (Rabbit)

1) Download a rabbit-capable detector model (Open Images SSD MobileNet v2):

- Run: `./scripts/download_openimages_ssd_mobilenetv2.sh`

2) Edit `config.yaml`:

- Set detector + rabbit id:
  - `cv.objs_detector: tf_openimages`
  - `cv.objs_target_class_id: 260`  (Open Images “Rabbit”)
- Optional UI overlay behavior:
  - `cv.objs_draw_mode: target` (or `all`)

3) Run the app, open the web UI, then:

- Click **OBJECTS**
- Click **UNLOCK** (tracking only drives the gimbal when unlocked)
- Set **Target class id** to `260` and click **SET TARGET**

## Web UI field

On the main page (Index), under **Advance CV Funcs**, there is a numeric field:
- **Target class id**

Clicking **SET TARGET** sends a `/ctrl` command that updates the running process.

Notes:
- This change is **runtime-only** (it is not written back to `config.yaml`).
- When the target is changed, tracking state is reset and the system reacquires a new target.

## Tracking behavior ("stick to one target")

When OBJECTS tracking is active:
- The detector runs every `cv.objs_detect_interval_frames` frames.
- A lightweight tracker runs every frame.
- Periodic detections are used to **confirm** the same target via IoU matching.
- If confirmation fails for too long (or the tracker fails repeatedly), the target is marked **lost** and the system will reacquire.

Key knobs:
- `cv.objs_detect_interval_frames`
- `cv.objs_confirm_timeout_s`
- `cv.objs_lost_fail_count`
- `cv.objs_iou_confirm_threshold`
- `cv.objs_tracker_type` (MOSSE/KCF/CSRT)

## Selecting other animals later

This implementation is based on a numeric **class id**.

### Where to find class ids

The exact meaning of `cv.objs_target_class_id` depends on `cv.objs_detector`:

- `tf_openimages`: the **numeric class id** used by the TensorFlow Object Detection API label map for Open Images.
  - For the recommended model (`ssd_mobilenet_v2_oid_v4_2018_12_12`), these ids are defined in TensorFlow’s Open Images label map:
    - `oid_bbox_trainable_label_map.pbtxt`
    - In the TensorFlow `models` GitHub repo, it typically lives at:
      - `models/research/object_detection/data/oid_bbox_trainable_label_map.pbtxt`
  - Practical lookup:
    1) Download that `*.pbtxt` somewhere on your Pi (or your dev machine).
    2) Search for the display name you want (example for Rabbit):
       - `grep -n "display_name: \"Rabbit\"" oid_bbox_trainable_label_map.pbtxt -n -B2 -A2`
    3) Use the nearby `id:` value as `cv.objs_target_class_id`.
  - Note: Open Images also has “MIDs” like `/m/...` in other metadata files; this repo’s current `tf_openimages` path uses the **numeric** `id:` from the TF label map.

- `caffe_voc`: the **VOC class index** from the hard-coded `class_names` list in `cv_ctrl.py`.
  - Practical lookup:
    - Check the list in `cv_ctrl.py` under the “cv_dnn_objects” section; the array index is the class id.
  - Note: VOC does not include rabbit.

### Drawing other detections

Drawing behavior is controlled by `cv.objs_draw_mode`:
- `all`: draw all detections (on frames where detection runs)
- `target`: draw only the currently selected/tracked target

## Files

- CV implementation: `cv_ctrl.py`
- Web UI: `templates/index.html`, `templates/control.js`
- Command handler: `app.py`
- Model download helper: `scripts/download_openimages_ssd_mobilenetv2.sh`
- Model notes: `models/openimages/README.md`
