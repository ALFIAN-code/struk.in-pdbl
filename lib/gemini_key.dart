// String geminiApi = 'AIzaSyAbVxDgaWpTpL3YyKdeHyGDXOcPSlE46bw';

import 'dart:math';

String getRandomApiKey() {
  List<String> apiKeys = [
    'AIzaSyAbVxDgaWpTpL3YyKdeHyGDXOcPSlE46bw',
    'AIzaSyAszq90S9Emzs-5peAlNYAi-nOBUFtXTSk',
    'AIzaSyC8hHoYlS7G3fq_jheY5MNdzZ9PS7gX8yE',
  ];

  final random = Random();
  int index = random.nextInt(apiKeys.length);
  return apiKeys[index];
}

String geminiApi = getRandomApiKey();
