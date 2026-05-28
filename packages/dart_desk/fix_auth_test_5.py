import re
with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'r') as f:
    content = f.read()

content = content.replace("          if (!_authReady.value) {", "          print('factory running! authReady=\${_authReady.value} authInfo=\${_authInfo.value}');\n          if (!_authReady.value) {")

with open('lib/src/cloud/dart_desk_auth_view_model.dart', 'w') as f:
    f.write(content)
