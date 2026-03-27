// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'studio_router.dart';

/// generated route for
/// [DocumentScreen]
class DocumentScreenRoute extends PageRouteInfo<DocumentScreenRouteArgs> {
  DocumentScreenRoute({
    Key? key,
    required String documentTypeSlug,
    required String documentId,
    List<PageRouteInfo>? children,
  }) : super(
         DocumentScreenRoute.name,
         args: DocumentScreenRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
           documentId: documentId,
         ),
         rawPathParams: {
           'documentTypeSlug': documentTypeSlug,
           'documentId': documentId,
         },
         initialChildren: children,
       );

  static const String name = 'DocumentScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DocumentScreenRouteArgs>(
        orElse: () => DocumentScreenRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
          documentId: pathParams.getString('documentId'),
        ),
      );
      return DocumentScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
        documentId: args.documentId,
      );
    },
  );
}

class DocumentScreenRouteArgs {
  const DocumentScreenRouteArgs({
    this.key,
    required this.documentTypeSlug,
    required this.documentId,
  });

  final Key? key;

  final String documentTypeSlug;

  final String documentId;

  @override
  String toString() {
    return 'DocumentScreenRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug, documentId: $documentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DocumentScreenRouteArgs) return false;
    return key == other.key &&
        documentTypeSlug == other.documentTypeSlug &&
        documentId == other.documentId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ documentTypeSlug.hashCode ^ documentId.hashCode;
}

/// generated route for
/// [DocumentTypeScreen]
class DocumentTypeScreenRoute
    extends PageRouteInfo<DocumentTypeScreenRouteArgs> {
  DocumentTypeScreenRoute({
    Key? key,
    required String documentTypeSlug,
    List<PageRouteInfo>? children,
  }) : super(
         DocumentTypeScreenRoute.name,
         args: DocumentTypeScreenRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
         ),
         rawPathParams: {'documentTypeSlug': documentTypeSlug},
         initialChildren: children,
       );

  static const String name = 'DocumentTypeScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DocumentTypeScreenRouteArgs>(
        orElse: () => DocumentTypeScreenRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
        ),
      );
      return DocumentTypeScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
      );
    },
  );
}

class DocumentTypeScreenRouteArgs {
  const DocumentTypeScreenRouteArgs({this.key, required this.documentTypeSlug});

  final Key? key;

  final String documentTypeSlug;

  @override
  String toString() {
    return 'DocumentTypeScreenRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DocumentTypeScreenRouteArgs) return false;
    return key == other.key && documentTypeSlug == other.documentTypeSlug;
  }

  @override
  int get hashCode => key.hashCode ^ documentTypeSlug.hashCode;
}

/// generated route for
/// [MediaScreen]
class MediaScreenRoute extends PageRouteInfo<void> {
  const MediaScreenRoute({List<PageRouteInfo>? children})
    : super(MediaScreenRoute.name, initialChildren: children);

  static const String name = 'MediaScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MediaScreen();
    },
  );
}

/// generated route for
/// [StudioShellScreen]
class StudioShellScreenRoute extends PageRouteInfo<void> {
  const StudioShellScreenRoute({List<PageRouteInfo>? children})
    : super(StudioShellScreenRoute.name, initialChildren: children);

  static const String name = 'StudioShellScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StudioShellScreen();
    },
  );
}

/// generated route for
/// [VersionScreen]
class VersionScreenRoute extends PageRouteInfo<VersionScreenRouteArgs> {
  VersionScreenRoute({
    Key? key,
    required String documentTypeSlug,
    required String documentId,
    required String versionId,
    List<PageRouteInfo>? children,
  }) : super(
         VersionScreenRoute.name,
         args: VersionScreenRouteArgs(
           key: key,
           documentTypeSlug: documentTypeSlug,
           documentId: documentId,
           versionId: versionId,
         ),
         rawPathParams: {
           'documentTypeSlug': documentTypeSlug,
           'documentId': documentId,
           'versionId': versionId,
         },
         initialChildren: children,
       );

  static const String name = 'VersionScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<VersionScreenRouteArgs>(
        orElse: () => VersionScreenRouteArgs(
          documentTypeSlug: pathParams.getString('documentTypeSlug'),
          documentId: pathParams.getString('documentId'),
          versionId: pathParams.getString('versionId'),
        ),
      );
      return VersionScreen(
        key: args.key,
        documentTypeSlug: args.documentTypeSlug,
        documentId: args.documentId,
        versionId: args.versionId,
      );
    },
  );
}

class VersionScreenRouteArgs {
  const VersionScreenRouteArgs({
    this.key,
    required this.documentTypeSlug,
    required this.documentId,
    required this.versionId,
  });

  final Key? key;

  final String documentTypeSlug;

  final String documentId;

  final String versionId;

  @override
  String toString() {
    return 'VersionScreenRouteArgs{key: $key, documentTypeSlug: $documentTypeSlug, documentId: $documentId, versionId: $versionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VersionScreenRouteArgs) return false;
    return key == other.key &&
        documentTypeSlug == other.documentTypeSlug &&
        documentId == other.documentId &&
        versionId == other.versionId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      documentTypeSlug.hashCode ^
      documentId.hashCode ^
      versionId.hashCode;
}
