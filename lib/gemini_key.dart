// String geminiApi = 'AIzaSyAbVxDgaWpTpL3YyKdeHyGDXOcPSlE46bw';

import 'dart:math';

String getRandomApiKey() {
  List<String> apiKeys = ['AIzaSyAbVxDgaWpTpL3YyKdeHyGDXOcPSlE46bw'];

  final random = Random();
  int index = random.nextInt(apiKeys.length);
  return apiKeys[index];
}

String geminiApi = getRandomApiKey();
