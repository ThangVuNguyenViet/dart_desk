import os

filepath = os.path.expanduser('~/.pub-cache/hosted/pub.dev/preact_signals-7.0.0/lib/src/globals.dart')
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("""void throwSignalEffectException(SignalEffectException error) {
  throw error;
}""", """void throwSignalEffectException(SignalEffectException error) {
  print('== SIGNAL EFFECT EXCEPTION: ${error.error}\\n${error.stackTrace} ==');
  throw error;
}""")

with open(filepath, 'w') as f:
    f.write(content)
