import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> appendToCredsFile(String id, String password) async {
  // Get the application documents directory
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

  // Construct the file path for the credentials file
  String filePath = '${appDocumentsDirectory.path}/creds.json';
  File credsFile = File(filePath);

  // Read existing content or create an empty list
  List<dynamic> existingData = [];
  if (credsFile.existsSync()) {
    String fileContent = credsFile.readAsStringSync();
    existingData = json.decode(fileContent);
  }

  dynamic userCreds = {'id': id, 'password': password};

  // Append new data
  if (!existingData.contains(userCreds)) {
    existingData.add(userCreds);
    // Write the updated content back to the file
    credsFile.writeAsStringSync(json.encode(existingData));
  }
}

List<List<String>> getCredsData() {
  List<List<String>> credentials=[
    ['arsawerw', 'qerqfv32423'],
    ['arsawerw', 'qerqfv32423'],
    ['arsawerw', 'qerqfv32423'],
  ];
  return credentials;
}
