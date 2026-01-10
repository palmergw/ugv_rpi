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
- For Open Images models, use the model’s numeric class id for the category you want.
- For the default VOC model (`caffe_voc`), the class ids are VOC indices (note: VOC does not include rabbit).

## Files

- CV implementation: `cv_ctrl.py`
- Web UI: `templates/index.html`, `templates/control.js`
- Command handler: `app.py`
- Model download helper: `scripts/download_openimages_ssd_mobilenetv2.sh`
- Model notes: `models/openimages/README.md`
