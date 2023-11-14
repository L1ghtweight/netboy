import 'dart:async';

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

    var usageMinutes = getParsedUsage(response.content()).toString();
    if (usageMinutes == "-1") {
      usageMinutes = "Couldn't fetch.";
    }
    print('$username: $usageMinutes');
    return usageMinutes;
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
  List<Future<List<String>>> futures = [];

  for (var credential in credentials) {
    var username = credential[0];
    var password = credential[1];
    futures
        .add(getUsage(username, password).then((usage) => [username, usage]));
  }

  return Future.wait(futures);
}
