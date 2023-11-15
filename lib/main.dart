import 'package:flutter/material.dart';

import 'credentials_manager.dart';
import 'test.dart' as test;

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
  List<List<String>> usageData = [];
  bool isDataFetched = false;

  @override
  void initState() {
    super.initState();
    // fetchUsageData();
  }

  Future<void> fetchUsageData() async {
    Stopwatch stopwatch = Stopwatch()..start();

    List<List<String>> data = await test.threadedCalls();
    stopwatch.stop();
    print("Fetched in: ${stopwatch.elapsed.inMilliseconds}");

    print("setting data");
    print(data);
    setState(() {
      usageData = data;
      isDataFetched = true;
    });
  }

  DataTable dataTable() {
    return DataTable(
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
      rows: usageData
          .asMap()
          .entries
          .map(
            (entry) => DataRow(
              cells: [
                DataCell(Text(entry.value[0])),
                DataCell(Text(entry.value[1])),
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Add or Edit ID',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CredentialsManager(
                    title: 'Add or Edit credentials',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: isDataFetched ? null : fetchUsageData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              // While the future is still running, show a loading indicator
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      dataTable(),
                      const CircularProgressIndicator(),
                      const Text(
                          'Please wait while we\'re fetching data from iusers.'),
                    ]),
              );
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.done:
              // When the future is complete, handle the data or display UI
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Your UI based on the fetched data
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[dataTable()]),
                );
              }
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await fetchUsageData();
          setState(() {
            isDataFetched = false;
            usageData = [];
          });
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.sync),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
