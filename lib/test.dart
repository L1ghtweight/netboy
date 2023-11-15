import 'dart:async';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';

var users = [
  ["", ""],
  ["", ""],
  ["", ""]
];

void main() async {
  // await noThr();
  // await Thr();

  Stopwatch stopwatch = Stopwatch()..start();
  var response = await threadedCalls();
  print(
      'Time taken with threads: ${stopwatch.elapsed.inMilliseconds} milliseconds');

  print(response);
  print("------------------");

  // stopwatch = Stopwatch()..start();
  // response = await normalCalls();
  // print(
  //     'Time taken without threads: ${stopwatch.elapsed.inMilliseconds} milliseconds');
  // print(response);
}

Future noThr() async {
  var uriPosts = Uri.parse('https://jsonplaceholder.typicode.com/posts/');
  var uriComments = Uri.parse('https://jsonplaceholder.typicode.com/comments');

  Stopwatch stopwatch = new Stopwatch()..start();

  var posts = await http.get(uriPosts);
  var comments = await http.get(uriComments);

  stopwatch.stop();
  print(
      'Time taken without threads: ${stopwatch.elapsed.inMilliseconds} milliseconds');
}

Future Thr() async {
  var uriPosts = Uri.parse('https://jsonplaceholder.typicode.com/posts/');
  var uriComments = Uri.parse('https://jsonplaceholder.typicode.com/comments');

  Stopwatch stopwatch = new Stopwatch()..start();

  final results =
      await Future.wait([http.get(uriPosts), http.get(uriComments)]);

  stopwatch.stop();
  print(
      'Time taken with threads: ${stopwatch.elapsed.inMilliseconds} milliseconds');
}

Future<List<List<String>>> normalCalls() async {
  List<List<String>> usage = [];
  for (final user in users) {
    usage.add(await getUsage(user[0], user[1]));
  }
  return usage;
}

Future<List<List<String>>> threadedCalls() {
  List<Future<List<String>>> futures = [];
  for (final user in users) {
    futures.add(getUsage(user[0], user[1]));
  }
  return Future.wait(futures);
}

Future<List<String>> getUsage(String username, String password) async {
  print("Call for: $username");
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
    return [username, usageMinutes];
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
  List<Future<List<String>>> futures = [];

  for (var credential in users) {
    var username = credential[0];
    var password = credential[1];
    futures.add(getUsage(username, password));
  }

  return Future.wait(futures);
}
