import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

import 'desk_frame.dart';

/// Convenience wrapper: a [DeskFrame] around `Image.network(ref.publicUrl ?? ref.externalUrl)`.
class DeskImageView extends StatelessWidget {
  DeskImageView(this.ref, {super.key, this.fit = BoxFit.cover})
      : assert(
          ref.publicUrl != null || ref.externalUrl != null,
          'DeskImageView requires publicUrl or externalUrl on the ImageReference',
        );

  final ImageReference ref;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = ref.publicUrl ?? ref.externalUrl!;
    return DeskFrame(
      ref: ref,
      fit: fit,
      child: Image.network(url, fit: BoxFit.fill),
    );
  }
}
