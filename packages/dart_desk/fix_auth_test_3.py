import re
with open('test/cloud/dart_desk_auth_view_model_test.dart', 'r') as f:
    content = f.read()

content = content.replace("when(() => userEndpoint.getCurrentUser()).thenThrow(", "when(() => userEndpoint.getCurrentUser()).thenAnswer((_) async => throw ")
content = content.replace("    );", "    );")

with open('test/cloud/dart_desk_auth_view_model_test.dart', 'w') as f:
    f.write(content)
