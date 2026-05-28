import os

filepath = os.path.expanduser('~/.pub-cache/hosted/pub.dev/preact_signals-7.0.0/lib/src/batch.dart')
with open(filepath, 'r') as f:
    content = f.read()

replacement = """class SignalEffectException implements Exception {
  final Object error;
  final StackTrace? stackTrace;
  const SignalEffectException(this.error, [this.stackTrace]);
  @override
  String toString() => 'SignalEffectException: $error\\n$stackTrace';
}"""

content = re.sub(r'class SignalEffectException implements Exception \{.*?(?=\n\n)', replacement, content, flags=re.DOTALL)
with open(filepath, 'w') as f:
    f.write(content)
