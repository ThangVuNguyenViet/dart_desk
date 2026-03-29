# Image Input Crop/Hotspot UX Design

**Date:** 2026-03-30
**Status:** Approved
**Scope:** `packages/dart_desk` image input/editor UX
**References:** `packages/dart_desk/lib/src/inputs/image_input.dart`, `packages/dart_desk/lib/src/inputs/hotspot/image_hotspot_editor.dart`, `packages/dart_desk/tests/qa/tests/11_image_upload_flow.md`

---

## Problem

The current image crop/hotspot feature is technically present, but the editing experience is weak:

- Crop and hotspot controls are shown together, which makes the canvas visually noisy
- Interaction depends on small drag targets and fine motor precision
- The editor offers little guidance about what the user is trying to achieve
- The action label `Edit crop` undersells the real task, which is defining final framing
- The preview strip does not communicate framing decisions clearly enough and appears to align mainly by hotspot rather than by the combined crop and hotspot result

This creates a feature that exists in code but does not feel confident or pleasant to author with.

## Goal

Redesign the editor so image framing feels guided, precise, and desktop-web oriented while preserving the existing data model:

- Keep `Hotspot` and `CropRect` as the stored representation
- Keep `ImageReference` as the document format
- Improve authoring UX without expanding schema or backend scope
- Optimize the workflow for desktop presentation targets first

## Recommended Approach

Adopt a Sanity-inspired framing editor with clearer guidance, but simplify it for common desktop web use cases.

Three approaches were considered:

1. `Mode-based canvas editor` — recommended
2. `Single-canvas direct manipulation` — lower effort, but still cognitively noisy
3. `Preset-first editor` — strong for hero/banner workflows, but too opinionated for a reusable CMS package

The recommended approach separates author intent into distinct modes while retaining one shared visual canvas and the current storage model.

---

## Section 1: Product Behavior

The image field remains compact in the form. Once an image exists, the field preview shows:

- the current image
- framing state summary such as `Default framing`, `Focus set`, or `Crop adjusted`
- a primary action labeled `Edit framing`

`Edit framing` replaces `Edit crop` because the feature is broader than trimming image bounds. Users are deciding how the image should adapt across desktop surfaces.

When opened, the editor presents a single large canvas plus mode controls:

- `Crop`
- `Focus`
- `Preview`

Default opening behavior:

- If the image has no custom framing yet, open in `Focus`
- If the image already has custom framing, reopen in the last-used mode

This default prioritizes the more valuable desktop-authoring action: choosing what must stay visible when aspect ratios change.

---

## Section 2: Interaction Model

### Crop mode

`Crop` mode edits the allowed image area only.

- Show the crop rectangle and crop handles
- Dim the outside region
- Use larger edge and corner hit targets than the current editor
- Allow freeform crop within the image bounds
- Do not force a fixed aspect ratio in the main editor canvas

Quick actions:

- `Reset crop`
- `Center image`

Future preset framing shortcuts are allowed, but not required in this iteration.

### Focus mode

`Focus` mode edits the focal region only.

- Hide crop handles to reduce noise
- Emphasize one focal ellipse with clear move and resize affordances
- Allow dragging the center and resizing the focus area
- Constrain the focal point to the uncropped region so focus cannot point at removed pixels

### Preview mode

`Preview` mode is read-only validation.

- Show side-by-side previews for `16:9 hero`, `4:3 card`, and `1:1 thumbnail`
- Apply both crop and hotspot to these previews
- Help users confirm framing before saving

### Actions

The editor toolbar/actions are:

- `Reset focus`
- `Reset crop`
- `Reset all`
- `Cancel`
- `Apply`

Behavior:

- `Cancel` discards all draft changes made in the dialog
- `Apply` commits the draft framing into the field value
- Reset actions affect only their intended dimension, except `Reset all`

This is a more explicit interaction contract than the current `Done` action.

---

## Section 3: Component Architecture

Keep [`CmsImageInput`](/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/packages/dart_desk/lib/src/inputs/image_input.dart) as the field entry point and preserve the current `ImageReference` output shape.

Refactor the editor into smaller units:

- `ImageFramingEditorDialog`
- `FramingCanvas`
- `CropLayer`
- `FocusLayer`
- `PreviewStrip`
- a local controller or draft-state object for framing edits

Responsibilities:

- `CmsImageInput` opens the framing editor and receives the applied result
- the dialog owns draft editing state
- canvas/layer widgets focus on visual interaction and geometry only
- preview widgets consume the same draft state and render derived outputs

No schema changes are required:

- `ImageReference`
- `Hotspot`
- `CropRect`
- upload flow
- backend persistence format

all remain intact.

---

## Section 4: State Flow

Initial state:

- `CmsImageInput` passes `initialHotspot` and `initialCrop` into the dialog
- missing values are replaced with sensible defaults

Editing:

- the dialog works on a local draft copy
- every UI interaction updates draft state only
- the field value outside the dialog remains unchanged until `Apply`

Apply flow:

1. User taps `Apply`
2. Draft `hotspot` and `crop` are copied into `ImageReference`
3. `CmsImageInput` updates local image state
4. `onChanged` emits the updated `toDocumentJson()` payload

Cancel flow:

1. User taps `Cancel`
2. Draft state is discarded
3. No field value changes are emitted

Reset flow:

- `Reset focus` restores default hotspot only
- `Reset crop` restores zero crop only
- `Reset all` restores both defaults

Field preview behavior:

- outside the dialog, the field preview shows a subtle framing summary badge so users can tell whether custom framing exists without reopening the editor

---

## Section 5: Error Handling

If the image fails to load in the framing dialog:

- show an inline error state inside the dialog
- offer `Retry` and `Close`
- avoid presenting a blank or broken canvas

If preview thumbnails fail:

- keep the main editor usable
- degrade the preview strip gracefully rather than blocking editing

If no crop or hotspot exists yet:

- initialize defaults immediately
- do not expose an “empty editor” state that requires extra setup before interaction

---

## Section 6: Testing Strategy

### Widget tests

Add widget tests for:

- mode switching between `Crop`, `Focus`, and `Preview`
- `Cancel` discarding dialog edits
- `Apply` persisting dialog edits
- `Reset focus`, `Reset crop`, and `Reset all`
- reopening the dialog with previously saved state

### Geometry-focused tests

Add targeted tests for the math most likely to regress:

- crop clamping to image bounds
- hotspot movement clamped to the uncropped region
- hotspot resize rules
- preview calculations that combine crop and hotspot

### QA coverage

Extend the existing image upload QA flow beyond open/close validation:

- open framing editor
- change crop
- change focus
- apply changes
- reopen and verify persistence
- reset only crop without removing focus
- reset only focus without removing crop

This aligns QA with actual user outcomes rather than simple dialog visibility.

---

## What Does Not Change

- `ImageReference.toDocumentJson()` format
- upload behavior
- media asset model
- backend endpoints
- public document image resolution work
- mobile-first framing presets

This project is a UX redesign of the editor layer only.

---

## Implementation Scope

1. Rename the primary field action from `Edit crop` to `Edit framing`
2. Refactor the current hotspot editor into smaller dialog/canvas/layer components
3. Introduce explicit `Crop`, `Focus`, and `Preview` modes
4. Replace current editor actions with explicit reset/cancel/apply actions
5. Update preview rendering so desktop target previews reflect both crop and hotspot
6. Add widget and geometry tests covering the new interaction model
