import 'package:dart_desk/src/inputs/number_input.dart';
import 'package:dart_desk/src/inputs/object_input.dart';
import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  // --- Fixtures ---

  const columnField = CmsObjectField(
    name: 'address',
    title: 'Address',
    description: 'Home address',
    option: CmsObjectOption(
      children: [
        ColumnFields(children: [
          CmsStringField(
            name: 'street',
            title: 'Street',
            option: CmsStringOption(),
          ),
          CmsStringField(
            name: 'city',
            title: 'City',
            option: CmsStringOption(),
          ),
        ]),
      ],
    ),
  );

  const rowField = CmsObjectField(
    name: 'location',
    title: 'Location',
    option: CmsObjectOption(
      children: [
        RowFields(children: [
          CmsStringField(
            name: 'lat',
            title: 'Latitude',
            option: CmsStringOption(),
          ),
          CmsStringField(
            name: 'lng',
            title: 'Longitude',
            option: CmsStringOption(),
          ),
        ]),
      ],
    ),
  );

  const groupField = CmsObjectField(
    name: 'settings',
    title: 'Settings',
    option: CmsObjectOption(
      children: [
        GroupFields(
          title: 'Advanced',
          description: 'Advanced settings',
          collapsible: true,
          collapsed: true,
          children: [
            ColumnFields(children: [
              CmsStringField(
                name: 'apiKey',
                title: 'API Key',
                option: CmsStringOption(),
              ),
            ]),
          ],
        ),
      ],
    ),
  );

  const mixedField = CmsObjectField(
    name: 'profile',
    title: 'Profile',
    option: CmsObjectOption(
      children: [
        ColumnFields(children: [
          CmsStringField(
            name: 'name',
            title: 'Name',
            option: CmsStringOption(),
          ),
        ]),
        RowFields(children: [
          CmsNumberField(
            name: 'age',
            title: 'Age',
            option: CmsNumberOption(),
          ),
          CmsStringField(
            name: 'email',
            title: 'Email',
            option: CmsStringOption(),
          ),
        ]),
        GroupFields(
          title: 'Metadata',
          collapsible: true,
          collapsed: false,
          children: [
            ColumnFields(children: [
              CmsStringField(
                name: 'notes',
                title: 'Notes',
                option: CmsStringOption(),
              ),
            ]),
          ],
        ),
      ],
    ),
  );

  const nestedGroupField = CmsObjectField(
    name: 'config',
    title: 'Config',
    option: CmsObjectOption(
      children: [
        GroupFields(
          title: 'Outer',
          children: [
            GroupFields(
              title: 'Inner',
              children: [
                ColumnFields(children: [
                  CmsStringField(
                    name: 'deep',
                    title: 'Deep Field',
                    option: CmsStringOption(),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // --- Tests ---

  group('CmsObjectInput', () {
    group('rendering', () {
      testWidgets('renders title and description', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: columnField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Home address'), findsOneWidget);
      });

      testWidgets('hidden field renders nothing', (tester) async {
        const hiddenField = CmsObjectField(
          name: 'hidden',
          title: 'Hidden',
          option: CmsObjectOption(children: [], hidden: true),
        );

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: hiddenField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Hidden'), findsNothing);
      });

      testWidgets('renders without description when null', (tester) async {
        const noDescField = CmsObjectField(
          name: 'simple',
          title: 'Simple',
          option: CmsObjectOption(
            children: [
              ColumnFields(children: [
                CmsStringField(
                  name: 'a',
                  title: 'A',
                  option: CmsStringOption(),
                ),
              ]),
            ],
          ),
        );

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: noDescField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Simple'), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
      });
    });

    group('ColumnFields', () {
      testWidgets('renders fields vertically', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: columnField),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CmsStringInput), findsNWidgets(2));
        expect(find.text('Street'), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
      });
    });

    group('RowFields', () {
      testWidgets('renders fields horizontally using Expanded', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: rowField),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CmsStringInput), findsNWidgets(2));
        // Both fields should be inside Expanded widgets within a Row
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Expanded), findsWidgets);
      });
    });

    group('GroupFields', () {
      testWidgets('renders group title', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: groupField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Advanced'), findsOneWidget);
      });

      testWidgets('renders group description when expanded', (tester) async {
        const expandedGroupField = CmsObjectField(
          name: 'settings',
          title: 'Settings',
          option: CmsObjectOption(
            children: [
              GroupFields(
                title: 'Advanced',
                description: 'Advanced settings',
                collapsible: true,
                collapsed: false,
                children: [
                  ColumnFields(children: [
                    CmsStringField(
                      name: 'apiKey',
                      title: 'API Key',
                      option: CmsStringOption(),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        );

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: expandedGroupField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Advanced settings'), findsOneWidget);
      });

      testWidgets('collapsed group hides children', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: groupField),
        ));
        await tester.pumpAndSettle();

        // Group is collapsed — child field should not be visible
        expect(find.text('API Key'), findsNothing);
        // Chevron-right icon should be visible (collapsed state)
        expect(
          find.byWidgetPredicate(
            (w) => w is FaIcon && w.icon == FontAwesomeIcons.chevronRight,
          ),
          findsOneWidget,
        );
      });

      testWidgets('tapping collapsed group expands it', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: groupField),
        ));
        await tester.pumpAndSettle();

        // Initially collapsed
        expect(find.text('API Key'), findsNothing);

        // Tap the group header to expand
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();

        // Now the child field should be visible
        expect(find.text('API Key'), findsOneWidget);
        // Chevron-down icon (expanded state)
        expect(
          find.byWidgetPredicate(
            (w) => w is FaIcon && w.icon == FontAwesomeIcons.chevronDown,
          ),
          findsOneWidget,
        );
      });

      testWidgets('tapping expanded group collapses it', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: groupField),
        ));
        await tester.pumpAndSettle();

        // Expand
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        expect(find.text('API Key'), findsOneWidget);

        // Collapse
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        expect(find.text('API Key'), findsNothing);
      });

      testWidgets('non-collapsible group always shows children',
          (tester) async {
        const nonCollapsibleField = CmsObjectField(
          name: 'info',
          title: 'Info',
          option: CmsObjectOption(
            children: [
              GroupFields(
                title: 'Details',
                collapsible: false,
                children: [
                  ColumnFields(children: [
                    CmsStringField(
                      name: 'desc',
                      title: 'Description',
                      option: CmsStringOption(),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        );

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: nonCollapsibleField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        // No chevron icon for non-collapsible groups
        expect(
          find.byWidgetPredicate(
            (w) => w is FaIcon && w.icon == FontAwesomeIcons.chevronRight,
          ),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is FaIcon && w.icon == FontAwesomeIcons.chevronDown,
          ),
          findsNothing,
        );
      });

      testWidgets('nested groups render recursively', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: nestedGroupField),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Outer'), findsOneWidget);
        expect(find.text('Inner'), findsOneWidget);
        expect(find.text('Deep Field'), findsOneWidget);
      });
    });

    group('mixed layouts', () {
      testWidgets('renders Column, Row, and Group together', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(field: mixedField),
        ));
        await tester.pumpAndSettle();

        // Column field
        expect(find.text('Name'), findsOneWidget);
        // Row fields
        expect(find.text('Age'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        // Group field (expanded)
        expect(find.text('Metadata'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);

        // CmsStringInput (Name, Email, Notes) + CmsNumberInput (Age)
        expect(find.byType(CmsStringInput), findsNWidgets(3));
        expect(find.byType(CmsNumberInput), findsOneWidget);
      });
    });

    group('data flow', () {
      testWidgets('passes initial data to child fields', (tester) async {
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: columnField,
            data: const CmsData(
              value: {'street': '123 Main St', 'city': 'Springfield'},
              path: 'address',
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('123 Main St'), findsOneWidget);
        expect(find.text('Springfield'), findsOneWidget);
      });

      testWidgets('onChanged fires with updated map on child edit',
          (tester) async {
        Map<String, dynamic>? received;

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: columnField,
            onChanged: (v) => received = v,
          ),
        ));
        await tester.pumpAndSettle();

        // Type into the first string input (Street)
        final inputs = find.byType(CmsStringInput);
        await tester.enterText(inputs.first, '456 Elm St');
        await tester.pump();

        expect(received, isNotNull);
        expect(received!['street'], '456 Elm St');
      });

      testWidgets('onChanged preserves existing values on partial edit',
          (tester) async {
        Map<String, dynamic>? received;

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: columnField,
            data: const CmsData(
              value: {'street': 'Original', 'city': 'OldCity'},
              path: 'address',
            ),
            onChanged: (v) => received = v,
          ),
        ));
        await tester.pumpAndSettle();

        // Edit only the city field (second input)
        final inputs = find.byType(CmsStringInput);
        await tester.enterText(inputs.at(1), 'NewCity');
        await tester.pump();

        expect(received, isNotNull);
        expect(received!['street'], 'Original');
        expect(received!['city'], 'NewCity');
      });

      testWidgets('onChanged emits a new map reference, not the internal map',
          (tester) async {
        final received = <Map<String, dynamic>?>[];

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: columnField,
            data: const CmsData(
              value: {'street': 'Original', 'city': 'A'},
              path: 'address',
            ),
            onChanged: received.add,
          ),
        ));
        await tester.pumpAndSettle();

        final inputs = find.byType(CmsStringInput);

        // Edit street, then city — each enterText may emit multiple times
        // (focus clears existing value → onChanged, then new value → onChanged)
        await tester.enterText(inputs.first, 'Edit 1');
        await tester.pump();

        await tester.enterText(inputs.at(1), 'Edit 2');
        await tester.pump();

        expect(received, isNotEmpty);

        // No two consecutive emissions should share the same instance
        for (var i = 1; i < received.length; i++) {
          expect(
            identical(received[i - 1], received[i]),
            isFalse,
            reason: 'emissions ${i - 1} and $i should be distinct instances',
          );
        }

        // Final emission must reflect both edits
        expect(received.last!['street'], 'Edit 1');
        expect(received.last!['city'], 'Edit 2');
      });

      testWidgets('updates child fields when data changes externally',
          (tester) async {
        const field = columnField;

        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: field,
            data: const CmsData(
              value: {'street': 'First', 'city': 'A'},
              path: 'address',
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);

        // Rebuild with new data
        await tester.pumpWidget(buildInputApp(
          CmsObjectInput(
            field: field,
            data: const CmsData(
              value: {'street': 'Second', 'city': 'B'},
              path: 'address',
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Second'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      });
    });

    group('flatFields', () {
      test('CmsObjectOption.fields collects all leaf fields', () {
        const option = CmsObjectOption(
          children: [
            ColumnFields(children: [
              CmsStringField(name: 'a', title: 'A', option: CmsStringOption()),
            ]),
            RowFields(children: [
              CmsStringField(name: 'b', title: 'B', option: CmsStringOption()),
              CmsStringField(name: 'c', title: 'C', option: CmsStringOption()),
            ]),
            GroupFields(
              title: 'Group',
              children: [
                ColumnFields(children: [
                  CmsStringField(
                    name: 'd',
                    title: 'D',
                    option: CmsStringOption(),
                  ),
                ]),
              ],
            ),
          ],
        );

        final fields = option.fields;
        expect(fields.length, 4);
        expect(fields.map((f) => f.name).toList(), ['a', 'b', 'c', 'd']);
      });

      test('nested GroupFields collects all leaf fields', () {
        const option = CmsObjectOption(
          children: [
            GroupFields(
              title: 'Outer',
              children: [
                GroupFields(
                  title: 'Inner',
                  children: [
                    RowFields(children: [
                      CmsStringField(
                        name: 'x',
                        title: 'X',
                        option: CmsStringOption(),
                      ),
                      CmsStringField(
                        name: 'y',
                        title: 'Y',
                        option: CmsStringOption(),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ],
        );

        final fields = option.fields;
        expect(fields.length, 2);
        expect(fields.map((f) => f.name).toList(), ['x', 'y']);
      });

      test('empty option returns empty fields', () {
        const option = CmsObjectOption(children: []);
        expect(option.fields, isEmpty);
      });
    });
  });
}
