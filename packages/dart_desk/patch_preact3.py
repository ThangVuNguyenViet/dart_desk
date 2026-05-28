import os

filepath = os.path.expanduser('~/.pub-cache/hosted/pub.dev/preact_signals-7.0.0/lib/src/globals.dart')
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("""void throwSignalEffectException(Object error) {
  throw error;
}""", """void throwSignalEffectException(Object error) {
  if (error.toString().contains('SignalEffectException')) {
    try {
      dynamic e = error;
      print('== SIGNAL EFFECT EXCEPTION: ${e.error}\\n${e.stackTrace} ==');
    } catch (_) {}
  }
  throw error;
}""")

with open(filepath, 'w') as f:
    f.write(content)

