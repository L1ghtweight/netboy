import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;
import 'package:requests/requests.dart';

import 'file_io_handler.dart';

Future<String> getUsage(String username, String password) async {
  const loginUrl = "http://10.220.20.12/index.php/home/loginProcess";
  final payload = {'username': username, 'password': password};
  final headers = {"Content-Type": "application/x-www-form-urlencoded"};

  try {
    var response = await Requests.post(
      loginUrl,
      headers: headers,
      body: payload,
      verify: true,
    );

    response = await Requests.post(
      loginUrl,
      headers: headers,
      body: payload,
      verify: true,
    );

    int usageMinutes = getParsedUsage(response.content());

    print(usageMinutes);
    return usageMinutes.toString();
  } on Exception catch (e) {
    print("Request Exception: $e");
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
  List<List<String>> usageData = [];
  for (var credential in credentials) {
    var username = credential[0];
    var password = credential[1];
    var usage = await getUsage(username, password);
    if (usageData.contains([username, usage]) == false) {
      usageData.add([username, usage]);
    }
  }
  return usageData;
}
