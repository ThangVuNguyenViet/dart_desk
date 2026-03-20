import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

/// A decoration wrapper for CmsDocumentType that includes visual elements like icons
class CmsDocumentTypeDecoration {
  /// The document type this decoration applies to
  final CmsDocumentType documentType;

  /// Icon to display for this document type
  final IconData? icon;

  /// Optional custom color for the icon and selection state
  final Color? color;
  const CmsDocumentTypeDecoration({
    required this.documentType,
    this.icon,
    this.color,
  });

  /// Creates a copy of this decoration with the given fields replaced
  CmsDocumentTypeDecoration copyWith({
    CmsDocumentType? documentType,
    IconData? icon,
    Color? color,
  }) {
    return CmsDocumentTypeDecoration(
      documentType: documentType ?? this.documentType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
