// lib/src/studio/config/cms_breakpoints.dart

/// CMS layout breakpoint names, used with ResponsiveBreakpoints.of(context).
abstract final class CmsBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;

  static const String mobileTag = 'MOBILE';
  static const String tabletTag = 'TABLET';
  static const String desktopTag = 'DESKTOP';
}
