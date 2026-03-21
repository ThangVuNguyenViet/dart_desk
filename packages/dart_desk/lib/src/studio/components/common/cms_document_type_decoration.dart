import 'package:flutter/material.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

/// A decoration wrapper for DocumentType that includes visual elements like icons
class DocumentTypeDecoration {
  /// The document type this decoration applies to
  final DocumentType documentType;

  /// Icon to display for this document type
  final IconData? icon;

  /// Optional custom color for the icon and selection state
  final Color? color;
  const DocumentTypeDecoration({
    required this.documentType,
    this.icon,
    this.color,
  });

  /// Creates a copy of this decoration with the given fields replaced
  DocumentTypeDecoration copyWith({
    DocumentType? documentType,
    IconData? icon,
    Color? color,
  }) {
    return DocumentTypeDecoration(
      documentType: documentType ?? this.documentType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
