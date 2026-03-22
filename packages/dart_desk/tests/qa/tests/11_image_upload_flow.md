# 11 - Image Upload Flow

Context: FakeImagePickerPlatform is installed in main_test.dart, so image picker calls return a test PNG instead of opening the native picker.

## Prerequisites
- App launched via main_test.dart with MockDataSource
- Marionette connected
- Document "Test Document Alpha" exists with image_field containing an ImageReference

## TC-11-01: Upload image via fake picker

**Steps:**
1. Tap "Test All Fields" in sidebar
2. Tap "Test Document Alpha" to select it
3. Use scrollByKey extension to scroll to 'image_field' area
4. Call get_interactive_elements to find the image upload button/area
5. Tap the upload button on the image field
6. Wait briefly for FakeImagePicker to return the test PNG
7. Call get_interactive_elements to check upload progress
8. Take screenshot to verify image preview

**Expected:**
- Upload completes without errors
- Image preview area shows the uploaded image (not empty placeholder)
- Upload state transitions visible if any loading indicator exists

## TC-11-02: Remove and Edit crop buttons appear after upload

**Steps:**
1. After TC-11-01, call get_interactive_elements in the image field area
2. Look for "Remove" button and "Edit crop" button (hotspot is enabled on the test field)

**Expected:**
- "Remove" button is visible
- "Edit crop" button is visible (since CmsImageOption has hotspot: true)

## TC-11-03: Remove clears image

**Steps:**
1. Tap "Remove" button on the image field
2. Call get_interactive_elements

**Expected:**
- Image preview is gone
- Upload button/empty placeholder is visible again
- "Remove" and "Edit crop" buttons are no longer visible

## TC-11-04: Upload persists after navigation

**Steps:**
1. Upload an image (tap upload button, wait for completion)
2. Save the document (look for save button, tap it)
3. Tap "Test Document Beta" in the document list to navigate away
4. Tap "Test Document Alpha" to navigate back
5. Use scrollByKey to scroll to image_field
6. Call get_interactive_elements

**Expected:**
- Image field still shows the image preview
- ImageReference data persists in the document

## TC-11-05: Upload fires onChanged with ImageReference

**Steps:**
1. Select "Test Document Beta" (which has null image_field)
2. Scroll to image_field
3. Tap upload button
4. Wait for upload to complete
5. Call get_interactive_elements to verify the preview area

**Expected:**
- Image preview appears in the previously empty field
- The document data now contains an ImageReference for image_field

## TC-11-06: Open Edit crop dialog

**Steps:**
1. Ensure "Test Document Alpha" is selected and has an uploaded image, scroll to image_field
2. Tap `edit_crop_button` (key)
3. Call `get_interactive_elements` to check for `hotspot_editor`, `reset_button`, `done_button`

**Expected:**
- Hotspot editor elements visible in the dialog

**ShadDialog fallback:** If elements not found after tapping edit_crop_button → mark SKIPPED with note "ShadDialog overlay not traversable by Marionette."

## TC-11-07: Edit crop Done saves

**Prerequisites:** TC-11-06 passed (not skipped)

**Steps:**
1. Tap `done_button`
2. Call `get_interactive_elements` to verify dialog closed

**Expected:**
- Dialog is dismissed
- Image field still shows the image preview and Edit crop button
