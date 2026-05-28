import re
with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'r') as f:
    content = f.read()

# Remove print and dependencies
content = content.replace("          print('factory running! authReady=\${_authReady.value} authInfo=\${_authInfo.value}');\n", "")
content = content.replace("        options: AsyncSignalOptions(dependencies: [_authReady, _authInfo], name: 'currentUser'),", "        options: AsyncSignalOptions(name: 'currentUser'),")

# Add currentUser.reload() in _onAuthChanged
content = content.replace("    _authInfo.value = next;", "    _authInfo.value = next;\n    currentUser.reload();")
content = content.replace("    print('onAuthChanged: prev=\${prev?.authUserId} next=\${next?.authUserId} equal=\${prev?.authUserId == next?.authUserId}');\n", "")

# Add currentUser.reload() in start()
content = content.replace("    batch(() {\n      _authInfo.value = sessionManager.authInfoListenable.value;\n      _authReady.value = true;\n    });", "    batch(() {\n      _authInfo.value = sessionManager.authInfoListenable.value;\n      _authReady.value = true;\n    });\n    currentUser.reload();")

with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'w') as f:
    f.write(content)
