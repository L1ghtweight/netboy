import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

Future<int> getUsage(String username, String password) async {
  String loginUrl = "http://10.220.20.12/index.php/home/loginProcess";

  var payload = "username=$username&password=$password";

  Map<String, String> headers = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Content-Type": "application/x-www-form-urlencoded",
  };

  try {
    http.Response response = await http
        .post(
          Uri.parse(loginUrl),
          headers: headers,
          body: payload,
        )
        .timeout(const Duration(seconds: 10));

    // Check the response status code
    print(response.statusCode);
    print(response.headers);
    print(response.body);
  } catch (e) {
    // Handle network or other errors
    print("Error during login: $e");
  }
  return 0;
}

Future<int> getUsageTest1(String username, String password) async {
  final session = http.Client();

  try {
    final headers = {"Content-Type": "application/x-www-form-urlencoded"};

    String data = "username=$username&password=$password";

    print(data);

    final response = await session.post(
        Uri.parse("http://10.220.20.12/index.php/home/login"),
        headers: headers,
        body: data);

    print(response.body);

    final document = htmlParser.parse(response.body);

    final table = document.querySelector("table.table.invoicefor");
    final tableBody = table?.querySelector("tbody");
    final rows = tableBody?.querySelectorAll("tr");

    List<List<String>> usageData = [];
    var extractedUsageData = 0;

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
  } finally {
    session.close();
  }
}

Future<int> getUsageTest2(String username, String password) async {
  final session = http.Client();

  try {
    final headers = {"Content-Type": "application/x-www-form-urlencoded"};

    String data = "username=$username&password=$password";

    print(data);

    final response = await session
        .post(Uri.parse("http://10.220.20.12/index.php/home/login"),
            headers: headers, body: data)
        .timeout(const Duration(seconds: 10));
    print(response.headers);
    print(response.body);

    return 0;
  } finally {
    session.close();
  }
}
