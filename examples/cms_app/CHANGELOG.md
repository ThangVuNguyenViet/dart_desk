## 1.1.0

 - **REFACTOR**: rename dart_desk_be_client to dart_desk_client.
 - **REFACTOR**: consolidate DartDeskBuiltInApp into DartDeskApp.
 - **REFACTOR**: replace dart_desk_be_client dep with onSignOut callback on StudioCoordinator.
 - **FIX**: restore Serializable bound, fix cms_app errors, unify workspace.
 - **FIX**(generator): support external projects outside workspace.
 - **FIX**: correct dependency paths and add marionette_flutter dep.
 - **FIX**: integration fixes for CMS studio architecture alignment.
 - **FEAT**: redesign example app with restaurant-themed data models.
 - **FEAT**: use flutter_colorpicker package for color input.
 - **FEAT**: wire up new document types in cms_app.
 - **FEAT**: send API key via Authorization header using DartDesk scheme.
 - **FEAT**: pass API_KEY from dart-define to DartDeskApp.
 - **FEAT**(cms_app): supply preview builder via DocumentTypeSpec.build().
 - **FEAT**: add field layout system for object inputs with row/column/group support.
 - **FEAT**: add cloud module with Serverpod IDP auth integration.
 - **FEAT**: render MediaBrowser for standalone media route in CmsStudio.
 - **FEAT**: add DartDeskApp widget, DartDeskConfig, DartDesk InheritedWidget.
 - **FEAT**: add media browser, hotspot input, E2E test infrastructure, and bug fixes.
 - **FEAT**: upgrade shadcn_ui to 0.52.1 and improve CMS input components.
 - **FEAT**: Wire up ZenRouter integration, exports, and example app.
 - **FEAT**: Update CMS app with auth integration and dependency updates.
 - **FEAT**: Add core data models for CMS including document, version, and media file management.
 - **DOCS**: update config to use project_id and dartdesk command name.

