# 02 - Real Media Handling

## TC-E2E-02-01: Upload image via UI
**Steps:**
1. Open a document with an image field
2. Tap the image upload button/area
3. Upload a test image file
4. Wait for upload to complete
5. Use `get_interactive_elements` to verify the image preview appears
6. Take a screenshot of the image preview

**Expected:**
- Image uploads successfully without errors
- Image preview is displayed in the form
- The image URL points to the backend storage

## TC-E2E-02-02: Upload non-image file
**Steps:**
1. Open a document with a file field
2. Tap the file upload button/area
3. Upload a test PDF or text file
4. Wait for upload to complete
5. Use `get_interactive_elements` to verify the file name/metadata appears

**Expected:**
- File uploads successfully
- File metadata (name, type) displayed correctly in the UI

## TC-E2E-02-03: Delete uploaded media
**Steps:**
1. Open a document with an uploaded image or file (from TC-E2E-02-01 or TC-E2E-02-02)
2. Tap the delete/remove button on the media field
3. Confirm deletion if prompted
4. Use `get_interactive_elements` to verify the media is removed

**Expected:**
- Media is removed from the field
- Image preview or file metadata no longer displayed

## TC-E2E-02-04: Image persists after save and reload
**Steps:**
1. Upload an image to a document field
2. Save the document
3. Navigate away from the document
4. Navigate back to the document
5. Use `get_interactive_elements` to check the image field

**Expected:**
- Image preview still loads from the backend URL
- No broken image indicators
