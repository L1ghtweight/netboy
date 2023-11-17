import 'dart:async';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

var users = [
  ["", ""],
  ["", ""],
  ["", ""],
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

  try {
    final headers0 = {"Content-Type": "application/x-www-form-urlencoded"};

    final client = http.Client(); // Create a new client for each call

    var response0 = await client.post(
      Uri.parse(loginUrl), 
      headers: headers0, 
      body: payload
    );
    var cookie = response0.headers['set-cookie'];
    print(cookie);

    final headers1 = {
      "Content-Type": "application/x-www-form-urlencoded",
      "cookie": cookie!
    };
    var response1 = await client.post(
      Uri.parse(loginUrl),
      headers: headers1,
      body: payload,
    );

    print(
        '***************################################### got response for id $username : ');

    var usageMinutes = getParsedUsage(response1.body).toString();
    if (usageMinutes == "-1") {
      usageMinutes = "Error 404!";
    }
    print('$username: $usageMinutes');
    client.close(); // Close the client after request completion
    return [username, usageMinutes];
  } catch (e) {
    print("Request Exception: $e");
    rethrow;
  }
}

int getParsedUsage(String body) {
  print(body);
  final document = html.parse(body);
  print(document.toString());

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
  List<Future<List<String>>> usageData = [];

  for (var credential in users) {
    var username = credential[0];
    var password = credential[1];
    usageData.add(getUsage(username, password));
  }

  return Future.wait(usageData);
}
