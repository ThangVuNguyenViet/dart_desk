import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Generate a valid 1x1 red PNG using the image package.
/// This ensures correct checksums for all PNG chunks, so
/// QuickMetadataExtractor can decode it without errors.
final Uint8List _testPngBytes = _generateTestPng();

Uint8List _generateTestPng() {
  final image = img.Image(width: 1, height: 1);
  image.setPixelRgb(0, 0, 255, 0, 0); // red pixel
  return Uint8List.fromList(img.encodePng(image));
}

/// A fake [ImagePickerPlatform] for e2e and integration testing.
///
/// When installed, calls to [ImagePicker.pickImage] will return a tiny test PNG
/// instead of opening the system file picker (which hangs on macOS desktop).
///
/// Usage:
/// ```dart
/// FakeImagePickerPlatform.install();
/// ```
class FakeImagePickerPlatform extends ImagePickerPlatform
    with MockPlatformInterfaceMixin {
  /// The [XFile] that [getImageFromSource] will return.
  /// Set to `null` to simulate the user cancelling the picker.
  XFile? imageToReturn;

  /// Creates a [FakeImagePickerPlatform] with a default 1x1 test PNG written
  /// to a temp file.
  FakeImagePickerPlatform() {
    final tempFile = File(
      '${Directory.systemTemp.path}/fake_image_picker_test.png',
    )..writeAsBytesSync(_testPngBytes);
    imageToReturn = XFile(tempFile.path, name: 'test_image.png');
  }

  /// Installs this fake as the active [ImagePickerPlatform.instance].
  ///
  /// Returns the installed instance so callers can reconfigure it if needed
  /// (e.g. set [imageToReturn] to `null` to simulate cancellation).
  static FakeImagePickerPlatform install() {
    final fake = FakeImagePickerPlatform();
    ImagePickerPlatform.instance = fake;
    return fake;
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return imageToReturn;
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    final image = imageToReturn;
    return image != null ? [image] : [];
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    return null;
  }

  @override
  Future<LostDataResponse> getLostData() async {
    return LostDataResponse.empty();
  }
}
