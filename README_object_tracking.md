# Object Tracking (OBJECTS mode)

This project includes an **OBJECTS** CV mode based on MobileNet-SSD (VOC) object detection, plus a simple **“stick to one until lost”** tracker.

## How to use

1. Start the app and open the web UI.
2. In **Advance CV Ctrl**, press **UNLOCK** (tracking will not move the gimbal while locked).
3. In **Advance CV Funcs**:
   - Use the **Track** dropdown to pick the object class to follow.
   - The selection auto-applies (it sends a `/ctrl` command and switches to **OBJECTS** mode).
4. The robot will:
   - Detect the chosen class, lock onto one instance, and drive the gimbal to center it.
   - Keep tracking that instance until the tracker loses it.
   - When lost, it returns to detection and reacquires a new instance of the selected class.

To stop tracking, set the dropdown to **Track: None**, or press **LOCK**.

## Target-only overlay

When a target is selected (anything except **Track: None**), the video overlay only draws boxes for that selected target. This makes it easier to confirm the robot is tracking the right thing.

## VOC class IDs (MobileNet-SSD)

The dropdown values map to these detector class IDs:

- 1 aeroplane
- 2 bicycle
- 3 bird
- 4 boat
- 5 bottle
- 6 bus
- 7 car
- 8 cat
- 9 chair
- 10 cow
- 11 diningtable
- 12 dog
- 13 horse
- 14 motorbike
- 15 person
- 16 pottedplant
- 17 sheep
- 18 sofa
- 19 train
- 20 tvmonitor

(0 is `background` and is not useful for tracking.)

## Implementation notes

- UI sends `/ctrl` messages of the form `{A: cv_objs, B: classId, C: 0}`.
- Backend reads `B` only for `cv_objs` and calls `set_objs_target_class()`.
- UI dropdown options are fetched from `/objs_labels` (falls back to VOC in the browser if unavailable).
- CV pipeline uses an OpenCV tracker (prefers CSRT; falls back to KCF/MOSSE if available).

## Wildlife preset (deer)

By default, OBJECTS uses the VOC label set (`cv.objs_preset: voc`).

To prepare for deer-style tracking, set:

- `cv.objs_preset: wildlife`

This changes the dropdown targets to debug-friendly options:

- `1 deer`
- `2 animal`
- `3 human`
- `4 vehicle`

The wildlife preset expects you to configure a detector model and (optionally) a deer-vs-not classifier in `config.yaml`:

- `cv.wildlife.class_map` maps your detector’s class IDs to `animal/human/vehicle`.
- `cv.deer_classifier.tflite_model` can be used to filter `animal` boxes down to `deer`.

## Debug overlay

By default the video overlay only shows the selected TARGET and LOCK/UNLOCK status.

To show additional on-screen diagnostics (tracker state, fail count, pan/tilt, last commanded X/Y), set:

- `cv.objs_debug: true` in `config.yaml`
