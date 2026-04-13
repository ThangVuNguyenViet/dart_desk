// ignore_for_file: avoid_print

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';

// A simple data class that implements Serializable
class BlogPost with Serializable<BlogPost> {
  final String title;
  final String body;
  final bool published;

  const BlogPost({
    required this.title,
    required this.body,
    this.published = false,
  });

  @override
  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'published': published,
  };
}

// Define the CMS document type with field configurations
final blogPostType = DocumentType<BlogPost>(
  name: 'blogPost',
  title: 'Blog Post',
  description: 'A blog post with title, body text, and publish status.',
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
      description: 'The main content of the blog post',
      option: CmsTextOption(rows: 5),
    ),
    CmsBooleanField(
      name: 'published',
      title: 'Published',
      description: 'Whether this post is publicly visible',
      option: CmsBooleanOption(),
    ),
    CmsImageField(
      name: 'coverImage',
      title: 'Cover Image',
      description: 'Hero image displayed at the top of the post',
      option: CmsImageOption(hotspot: true),
    ),
  ],
  builder: (data) => Text(data['title'] as String? ?? 'Untitled'),
  defaultValue: const BlogPost(title: 'New Post', body: ''),
);

// Using validators
void validatorExample() {
  final required = RequiredValidator<String>();

  // Returns null when value is present
  final valid = required('Title', 'Hello World');
  print('Valid result: $valid'); // null

  // Returns an error message when value is missing
  final invalid = required('Title', null);
  print('Invalid result: $invalid'); // "Title is required"
}

// Using the @CmsConfig annotation to mark a class for code generation
@CmsConfig(
  title: 'Site Settings',
  description: 'Global configuration for the site',
  id: 'siteSettings',
)
class SiteSettingsConfig {
  // This class is processed by dart_desk_generator to create CMS UI components
}

void main() {
  print('Blog post type: ${blogPostType.name}');
  print('Fields: ${blogPostType.fields.map((f) => f.name).join(', ')}');
  validatorExample();
}
