import re
with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'r') as f:
    content = f.read()

content = content.replace("    _authInfo.value = next;\n    currentUser.reload();", "    _authInfo.value = next;")
content = content.replace("    batch(() {\n      _authInfo.value = sessionManager.authInfoListenable.value;\n      _authReady.value = true;\n    });\n    currentUser.reload();", "    batch(() {\n      _authInfo.value = sessionManager.authInfoListenable.value;\n      _authReady.value = true;\n    });")

with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'w') as f:
    f.write(content)
