import 'package:signals/signals.dart';

Future<String> fetchData() async {
  await Future.delayed(Duration(milliseconds: 100));
  return "hello";
}

void main() async {
  print("Starting");
  
  // Tracked creation
  final sig1 = FutureSignal(() => fetchData());
  
  // Untracked creation
  final sig2 = untracked(() => FutureSignal(() => fetchData()));
  
  print("Sig1 state: ${sig1.value}");
  print("Sig2 state: ${sig2.value}");
  
  await Future.delayed(Duration(milliseconds: 200));
  
  print("Sig1 state later: ${sig1.value}");
  print("Sig2 state later: ${sig2.value}");
}
