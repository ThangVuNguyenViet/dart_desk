import re
with open('test/cloud/dart_desk_auth_view_model_test.dart', 'r') as f:
    content = f.read()

# Replace `await settle();` with `vm.currentUser.value; await pumpEventQueue();`
content = content.replace("await settle();", "vm.currentUser.value;\n    await pumpEventQueue(times: 50);")

# Remove the old `settle()` function
content = re.sub(r'  Future<void> settle\(\) async \{\n    await pumpEventQueue\(times: 50\);\n  \}\n', '', content)

with open('test/cloud/dart_desk_auth_view_model_test.dart', 'w') as f:
    f.write(content)
