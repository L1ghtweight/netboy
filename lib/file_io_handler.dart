import 'dart:convert';
import 'dart:io';

// import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> updateCredsFile(List<List<String>> updatedCreds) async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String filePath = '${appDocumentsDirectory.path}/creds.json';
  File credsFile = File(filePath);

  // Convert List<List<String>> to List<dynamic>
  List<dynamic> jsonData = updatedCreds.map((cred) {
    return {'id': cred[0], 'password': cred[1]};
  }).toList();

  // Write the updated data to the file
  credsFile.writeAsStringSync(json.encode(jsonData));
}

Future<List<List<String>>> readCredsFile() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String filePath = '${appDocumentsDirectory.path}/creds.json';
  File credsFile = File(filePath);

  if (!credsFile.existsSync()) {
    return [];
  }

  String fileContent = credsFile.readAsStringSync();
  List<dynamic> jsonData = json.decode(fileContent);

  List<List<String>> credsList = jsonData.map((cred) {
    return [cred['id'].toString(), cred['password'].toString()];
  }).toList();

  return credsList;
}
