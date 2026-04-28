import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/studio.dart';
import 'package:flutter/material.dart';

import 'document_types.dart';

Future<Widget> buildDeskApp({
  required DataSource dataSource,
  required VoidCallback onSignOut,
  DartDeskConfig? config,
}) async {
  return DartDeskApp.withDataSource(
    dataSource: dataSource,
    onSignOut: onSignOut,
    config: config ?? _config,
  );
}

final _config = DartDeskConfig(
  documentTypes: [
    homeDocumentType,
    kioskDocumentType,
    chefDocumentType,
    menuDocumentType,
    rewardsDocumentType,
    brandThemeDocumentType,
  ],
  documentTypeDecorations: [
    DocumentTypeDecoration(
      documentType: homeDocumentType,
      icon: Icons.home,
    ),
    DocumentTypeDecoration(
      documentType: kioskDocumentType,
      icon: Icons.tv_rounded,
    ),
    DocumentTypeDecoration(
      documentType: chefDocumentType,
      icon: Icons.restaurant,
    ),
    DocumentTypeDecoration(
      documentType: menuDocumentType,
      icon: Icons.menu_book,
    ),
    DocumentTypeDecoration(
      documentType: rewardsDocumentType,
      icon: Icons.star,
    ),
    DocumentTypeDecoration(
      documentType: brandThemeDocumentType,
      icon: Icons.palette,
    ),
  ],
  title: 'Food Ordering CMS',
  subtitle: 'White-Label App Studio',
  icon: Icons.restaurant,
);
