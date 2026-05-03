# dart_desk_widgets

Runtime Flutter widgets for rendering content authored in the
[dart_desk](https://github.com/ThangVuNguyenViet/dart_desk) studio.

## What's here

- **`DeskFrame`** — a layout wrapper that frames its child according to the
  `crop` and `hotspot` metadata on an `ImageReference`. The child is any
  widget that fills its parent box.
- **`DeskImageView`** — convenience: `DeskFrame` around `Image.network(ref.url)`.

This package is intentionally minimal and depends only on
`dart_desk_annotation` and Flutter — consumer apps can use it without
pulling in the heavier studio package.

## Usage

```dart
import 'package:dart_desk_widgets/dart_desk_widgets.dart';

// Simple case
DeskImageView(myImageRef, fit: BoxFit.cover);

// Custom child
DeskFrame(
  ref: myImageRef,
  fit: BoxFit.cover,
  child: CachedNetworkImage(
    imageUrl: myImageRef.publicUrl!,
    fit: BoxFit.fill, // child must fill its allocated box
  ),
);
```
