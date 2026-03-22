# 07 - Image Upload E2E

Context: FakeImagePickerPlatform is installed in main_e2e.dart, enabling image picker automation. The real CloudDataSource backend handles file storage.

## Prerequisites
- E2E environment: Serverpod backend running on localhost:8080
- Docker containers up (database, Redis)
- App launched via main_e2e.dart
- Marionette connected
- FakeImagePickerPlatform installed (returns a 1x1 test PNG)

## TC-E2E-07-01: Upload image → backend receives file with metadata
**Steps:**
1. Navigate to a document with an image field
2. Scroll to the image field area
3. Tap the upload button on the image field
4. Wait for FakeImagePicker to return the test PNG
5. Wait for upload progress to complete (metadata extraction → upload → done)
6. Call get_interactive_elements to verify image preview appears
7. Verify backend received the asset:
   ```
   curl http://localhost:8080/api/media/list
   ```

**Expected:**
- Image preview appears in the field
- Backend API returns the uploaded asset with metadata (width, height, blurHash, contentHash)
- Asset has mimeType 'image/png'

## TC-E2E-07-02: Uploaded image persists after save and reload
**Steps:**
1. After upload from TC-E2E-07-01, save the document
2. Navigate away from the document
3. Navigate back to the document
4. Scroll to the image field
5. Call get_interactive_elements to verify image preview
6. Verify document data via backend:
   ```
   curl http://localhost:8080/api/documents/{id}
   ```

**Expected:**
- Image field shows the image preview (loaded from backend URL)
- Document data in backend contains ImageReference with assetId pointing to the uploaded asset
- No broken image indicators

## TC-E2E-07-03: Upload, save, then delete image → data cleared
**Steps:**
1. With image uploaded and saved (from TC-E2E-07-02)
2. Scroll to image field, find "Remove" button
3. Tap "Remove"
4. Save the document
5. Call get_interactive_elements to verify field is empty
6. Verify document data via backend:
   ```
   curl http://localhost:8080/api/documents/{id}
   ```

**Expected:**
- Image field returns to empty/upload state
- Document data no longer contains ImageReference for image_field
- The media asset itself may still exist in the media library (not deleted from storage)

## TC-E2E-07-04: Upload same image twice → backend deduplicates
**Steps:**
1. Upload image to document A's image field (FakeImagePicker returns same test PNG)
2. Save document A
3. Navigate to document B
4. Upload image to document B's image field (same test PNG again)
5. Save document B
6. Query backend for media assets:
   ```
   curl http://localhost:8080/api/media/list
   ```

**Expected:**
- Both documents reference the same assetId (deduplication by content hash)
- Only one media asset entry exists for the test PNG
- Both document image_field data contain ImageReference with the same assetId
