import re
with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'r') as f:
    content = f.read()

content = content.replace("    if (prev?.authUserId == next?.authUserId) return;", "    print('onAuthChanged: prev=\${prev?.authUserId} next=\${next?.authUserId}');\n    if (prev?.authUserId == next?.authUserId) return;")

with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'w') as f:
    f.write(content)
