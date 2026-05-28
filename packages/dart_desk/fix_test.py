import re
with open('test/media/media_browser_state_test.dart', 'r') as f:
    content = f.read()
content = content.replace("await state.deleteAsset('asset-icon');", "await state.deleteAsset('asset-icon');\n        await pumpEventQueue();")
content = content.replace("await state.confirmAndDelete(asset);", "await state.confirmAndDelete(asset);\n        await pumpEventQueue();")
with open('test/media/media_browser_state_test.dart', 'w') as f:
    f.write(content)
