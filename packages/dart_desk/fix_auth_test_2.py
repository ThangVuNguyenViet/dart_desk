import re
with open('test/cloud/dart_desk_auth_view_model_test.dart', 'r') as f:
    content = f.read()

# Instead of manually reading `vm.currentUser.value`, we use `effect` to keep it warm.
content = content.replace("final vm = build();", "final vm = build();\n    final dispose = effect(() => vm.currentUser.value);")
content = content.replace("vm.dispose();", "dispose();\n    vm.dispose();")

# Remove the standalone `vm.currentUser.value;` calls that we added earlier
content = content.replace("vm.currentUser.value;\n    await pumpEventQueue(times: 50);", "await pumpEventQueue(times: 50);")
content = content.replace("      vm.currentUser.value;\n      await vm.start();", "      await vm.start();")

with open('test/cloud/dart_desk_auth_view_model_test.dart', 'w') as f:
    f.write(content)
