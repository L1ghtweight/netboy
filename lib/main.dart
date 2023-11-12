import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NetBoy',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NetBoy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<int> getUsage(String user, String pass) async {
    String loginUrl = "http://10.220.20.12/index.php/home/loginProcess";

    var payload = "username=$user&password=$pass";

    Map<String, String> headers = {
      "Accept": "*/*",
      "Accept-Encoding": "gzip, deflate, br",
      "Connection": "keep-alive",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    try {
      http.Response response = await http.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: payload,
      ).timeout(const Duration(seconds: 10));

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

  Future<int> __getUsage(String username, String password) async {
    final session = http.Client();

    try {
      final headers = {"Content-Type": "application/x-www-form-urlencoded"};

      String data = "username=$username&password=$password";

      print(data);

      final response = await session.post(
          Uri.parse("http://10.220.20.12/index.php/home/login"),
          headers: headers,
          body: data).timeout(const Duration(seconds: 10));
      print(response.headers);
      print(response.body);

      return 0;
    } finally {
      session.close();
    }
  }

  Future<int> _getUsage(String username, String password) async {
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

  void showAddIDDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController idController = TextEditingController();
        TextEditingController passwordController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  hintText: 'Enter ID',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog box
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Process the entered ID and password
                String id = idController.text;
                String password = passwordController.text;

                // Append to the creds.json file
                appendToCredsFile(id, password);

                // Close the dialog box
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void fetchData() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //call function that fetches data from net.iut-dhaka.edu
    });
  }

  List<DataRow> getUserUsageData() {
    return (<DataRow>[
      DataRow(
        cells: <DataCell>[
          DataCell(Text('Sarah')),
          DataCell(Text('19')),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          DataCell(Text('Janine')),
          DataCell(Text('43')),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          DataCell(Text('William')),
          DataCell(Text('27')),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add ID',
            onPressed: () {
              // Add button functionality here
              showAddIDDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Username',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Usage',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
              rows: getUserUsageData(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          const _username = "write user name";
          const _pass = "write password";
          print(await __getUsage(_username, _pass));
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.sync),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
