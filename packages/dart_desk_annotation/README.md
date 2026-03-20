# dart_desk_annotation

Annotations and field definitions for the [Dart Desk](https://github.com/vietthangvunguyen/dart_desk) CMS framework.

This package provides the core annotations and field configuration classes used to define CMS document types, fields, and validators. It is designed to have minimal dependencies and is suitable as a compile-time dependency.

## Installation

```sh
dart pub add dart_desk_annotation
```

## Usage

### Annotating a CMS configuration class

Use `@CmsConfig` to mark a class as a CMS configuration. This annotation is picked up by `dart_desk_generator` to generate CMS UI and data models.

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

@CmsConfig(
  title: 'Blog Post',
  description: 'A blog post document type',
)
class BlogPostConfig {
  // Fields are defined via CmsDocumentType
}
```

### Defining a document type with fields

Use `CmsDocumentType` to define the schema for a content type, including its fields and a preview builder.

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

final blogPostType = CmsDocumentType<BlogPost>(
  name: 'blogPost',
  title: 'Blog Post',
  description: 'A blog post with title, body, and cover image.',
  fields: [
    CmsStringField(
      name: 'title',
      title: 'Title',
      description: 'The title of the blog post',
      option: CmsStringOption(),
    ),
    CmsTextField(
      name: 'body',
      title: 'Body',
      option: CmsTextOption(),
    ),
    CmsImageField(
      name: 'coverImage',
      title: 'Cover Image',
      option: CmsImageOption(),
    ),
    CmsBooleanField(
      name: 'published',
      title: 'Published',
      option: CmsBooleanOption(),
    ),
  ],
  builder: (data) => Text(data['title'] as String? ?? ''),
);
```

### Using validators

`CmsValidator` and `RequiredValidator` can be attached to fields to enforce input constraints.

```dart
final validator = RequiredValidator<String>();
// validator('Title', null) returns 'Title is required'
```

## Field types

### Primitive
- `CmsStringField` / `CmsStringFieldConfig`
- `CmsTextField` / `CmsTextFieldConfig`
- `CmsNumberField` / `CmsNumberFieldConfig`
- `CmsBooleanField` / `CmsBooleanFieldConfig`
- `CmsCheckboxField` / `CmsCheckboxFieldConfig`
- `CmsDateField` / `CmsDateFieldConfig`
- `CmsDatetimeField` / `CmsDatetimeFieldConfig`
- `CmsUrlField` / `CmsUrlFieldConfig`

### Complex
- `CmsArrayField` / `CmsArrayFieldConfig`
- `CmsBlockField` / `CmsBlockFieldConfig`
- `CmsDropdownField` / `CmsDropdownFieldConfig`
- `CmsGeopointField` / `CmsGeopointFieldConfig`
- `CmsObjectField` / `CmsObjectFieldConfig`

### Media
- `CmsImageField` / `CmsImageFieldConfig`
- `CmsFileField` / `CmsFileFieldConfig`
- `CmsColorField` / `CmsColorFieldConfig`

## License

MIT — see [LICENSE](LICENSE)
