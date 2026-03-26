// packages/dart_desk/integration_test/test_utils/test_document_type.dart
import 'package:dart_desk/studio.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';

/// A minimal document type used exclusively in integration tests.
/// Covers string, image, and file fields needed by the test cases.
final integrationTestDocumentType = DocumentType(
  name: 'integration_test_doc',
  title: 'Integration Test',
  description: 'Document type used for integration testing',
  fields: [
    const CmsStringField(name: 'title', title: 'Title'),
    const CmsTextField(name: 'body', title: 'Body'),
    const CmsImageField(name: 'image_field', title: 'Image'),
    const CmsFileField(name: 'file_field', title: 'File'),
  ],
  builder: (data) => Text(data['title']?.toString() ?? ''),
  defaultValue: null,
);

final integrationTestDocumentTypeDecoration = DocumentTypeDecoration(
  documentType: integrationTestDocumentType,
  icon: Icons.science,
);
