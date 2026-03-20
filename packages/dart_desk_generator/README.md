# dart_desk_generator

Code generators for Flutter CMS.

This package contains the code generation logic for the Flutter CMS system,
including generators for data models, field configurations, and UI components.

## Usage

This package is typically used as a dev dependency:

```yaml
dev_dependencies:
  dart_desk_generator: ^0.1.0
  build_runner: ^2.4.0
```

Then configure it in your `build.yaml`:

```yaml
targets:
  $default:
    builders:
      dart_desk_generator|cmsBuilder:
        enabled: true
```
