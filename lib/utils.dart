import 'dart:async';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

import 'file_io_handler.dart';

Future<List<String>> getUsage(String username, String password) async {
  const loginUrl = "http://10.220.20.12/index.php/home/loginProcess";
  final payload = {'username': username, 'password': password};

  try {
    final headers0 = {"Content-Type": "application/x-www-form-urlencoded"};

    final client = http.Client(); // Create a new client for each call

    var response0 = await client.post(Uri.parse(loginUrl),
        headers: headers0, body: payload);
    var cookie = response0.headers['set-cookie'];

    final headers1 = {
      "Content-Type": "application/x-www-form-urlencoded",
      "cookie": cookie!
    };
    var response1 = await client.post(
      Uri.parse(loginUrl),
      headers: headers1,
      body: payload,
    );

    var usageMinutes = getParsedUsage(response1.body).toString();
    if (usageMinutes == "-1") {
      usageMinutes = "Error 404!";
    }
    client.close(); // Close the client after request completion
    return [username, usageMinutes];
  } catch (e) {
    rethrow;
  }
}

int getParsedUsage(String body) {
  final document = html.parse(body);
  final table = document.querySelector("table.table.invoicefor");
  final tableBody = table?.querySelector("tbody");
  final rows = tableBody?.querySelectorAll("tr");

  List<List<String>> usageData = [];
  var extractedUsageData = -1;

  if (rows != null) {
    for (var row in rows) {
      final cols = row.querySelectorAll("td");
      final colsText = cols.map((col) => col.text.trim()).toList();
      usageData.add(colsText);
    }

    extractedUsageData =
        int.parse(usageData[5][1].replaceAll(' Minute', '').trim());
  }

  return extractedUsageData;
}

Future<List<List<String>>> getUserUsageData() async {
  List<List<String>> credentials = await readCredsFile();
  List<Future<List<String>>> usageData = [];

  for (var credential in credentials) {
    var username = credential[0];
    var password = credential[1];
    usageData.add(getUsage(username, password));
  }

  return Future.wait(usageData);
}
