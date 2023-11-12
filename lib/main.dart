import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'utils.dart' as utils;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NetBoy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      //call function that fetches data from net.iut-dhaka.edu
    });
  }

  List<DataRow> getUserUsageData() {
    return (<DataRow>[
      const DataRow(
        cells: <DataCell>[
          DataCell(Text('Sarah')),
          DataCell(Text('19')),
        ],
      ),
      const DataRow(
        cells: <DataCell>[
          DataCell(Text('Janine')),
          DataCell(Text('43')),
        ],
      ),
      const DataRow(
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
          var env = DotEnv(includePlatformEnvironment: true)..load();
          var username = env['USERNAME'];
          var password = env['PASSWORD'];

          if (username != null && password != null) {
            utils.getUsage(username, password);
          }
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.sync),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
