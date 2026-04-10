import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Generate a valid 1x1 red PNG.
final Uint8List _testPngBytes = _generateTestPng();

Uint8List _generateTestPng() {
  final image = img.Image(width: 1, height: 1);
  image.setPixelRgb(0, 0, 255, 0, 0);
  return Uint8List.fromList(img.encodePng(image));
}

/// A fake [FilePicker] for integration testing.
///
/// When installed, calls to [FilePicker.platform.pickFiles] return a tiny
/// test PNG with bytes loaded, instead of opening the system file dialog.
///
/// Usage:
/// ```dart
/// FakeFilePickerPlatform.install();
/// ```
class FakeFilePickerPlatform extends FilePicker with MockPlatformInterfaceMixin {
  /// The result that [pickFiles] will return.
  /// Set to `null` to simulate user cancellation.
  FilePickerResult? resultToReturn;

  FakeFilePickerPlatform() {
    resultToReturn = FilePickerResult([
      PlatformFile(
        name: 'test_image.png',
        size: _testPngBytes.length,
        bytes: _testPngBytes,
      ),
    ]);
  }

  /// Installs this fake as the active [FilePicker.platform].
  static FakeFilePickerPlatform install() {
    final fake = FakeFilePickerPlatform();
    FilePicker.platform = fake;
    return fake;
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return resultToReturn;
  }
}
