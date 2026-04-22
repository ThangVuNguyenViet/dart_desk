# dart_desk_annotation

Annotations and field definitions for the [Dart Desk](https://github.com/ThangVuNguyenViet/dart_desk) CMS framework.

This package provides the core annotations and field configuration classes used to define CMS document types, fields, and validators. It is designed to have minimal dependencies and is suitable as a compile-time dependency.

## Installation

```sh
dart pub add dart_desk_annotation
```

## Usage

### Annotating a CMS configuration class

Use `@DeskModel` to mark a class as a CMS configuration. This annotation is picked up by `dart_desk_generator` to generate CMS UI and data models.

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';

@DeskModel(
  title: 'Blog Post',
  description: 'A blog post document type',
)
class BlogPostConfig {
  // Fields are defined via DeskDocumentType
}
```

### Defining a document type with fields

Use `DeskDocumentType` to define the schema for a content type, including its fields and a preview builder.

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

final blogPostType = DeskDocumentType<BlogPost>(
  name: 'blogPost',
  title: 'Blog Post',
  description: 'A blog post with title, body, and cover image.',
  fields: [
    DeskStringField(
      name: 'title',
      title: 'Title',
      description: 'The title of the blog post',
      option: DeskStringOption(),
    ),
    DeskTextField(
      name: 'body',
      title: 'Body',
      option: DeskTextOption(),
    ),
    DeskImageField(
      name: 'coverImage',
      title: 'Cover Image',
      option: DeskImageOption(),
    ),
    DeskBooleanField(
      name: 'published',
      title: 'Published',
      option: DeskBooleanOption(),
    ),
  ],
  builder: (data) => Text(data['title'] as String? ?? ''),
);
```

### Using validators

`DeskValidator` and `RequiredValidator` can be attached to fields to enforce input constraints.

```dart
final validator = RequiredValidator<String>();
// validator('Title', null) returns 'Title is required'
```

## Field types

### Primitive
- `DeskStringField` / `DeskString`
- `DeskTextField` / `DeskText`
- `DeskNumberField` / `DeskNumber`
- `DeskBooleanField` / `DeskBoolean`
- `DeskCheckboxField` / `DeskCheckbox`
- `DeskDateField` / `DeskDate`
- `DeskDatetimeField` / `DeskDatetimeFieldConfig`
- `DeskUrlField` / `DeskUrl`

### Complex
- `DeskArrayField` / `DeskArray`
- `DeskBlockField` / `DeskBlock`
- `DeskDropdownField` / `DeskDropdown`
- `DeskGeopointField` / `DeskGeopoint`
- `DeskObjectField` / `DeskObject`

### Media
- `DeskImageField` / `DeskImage`
- `DeskFileField` / `DeskFile`
- `DeskColorField` / `DeskColor`

## License

BSD 3-Clause — see [LICENSE](LICENSE)
