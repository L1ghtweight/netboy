import 'package:flutter/material.dart';

import 'file_io_handler.dart';
import 'ui_components.dart' as ui;

class CredentialsManager extends StatefulWidget {
  const CredentialsManager({super.key, required this.title});

  final String title;

  @override
  State<CredentialsManager> createState() => _CredentialsManagerState();
}

class _CredentialsManagerState extends State<CredentialsManager> {
  List<List<String>> credsData = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    List<List<String>> data = await readCredsFile();
    setState(() {
      credsData = data;
    });
  }

  void showAddIDDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController idController = TextEditingController();
        TextEditingController passwordController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Net ID'),
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

                String snackBarMessage = "Added user";

                setState(() {
                  bool duplicate = credsData.any((sublist) =>
                      sublist.contains(id) && sublist.contains(password));

                  if (!duplicate) {
                    credsData.add([id, password]);
                    updateCredsFile(credsData);
                  } else {
                    snackBarMessage = "User already exists";
                  }
                });

                // Close the dialog box
                Navigator.pop(context);

                // show the snackbar
                final snackBar = ui.getSnackbar(snackBarMessage);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void editCredsDialog(BuildContext context, int _index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController idController =
            TextEditingController(text: credsData[_index][0]);
        TextEditingController passwordController =
            TextEditingController(text: credsData[_index][1]);

        return AlertDialog(
          title: const Text('Edit Net ID'),
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
                decoration: const InputDecoration(
                  hintText: 'Enter Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  credsData.removeAt(_index);
                  updateCredsFile(credsData);
                  // show the snackbar
                  String snackBarMessage = "Removed user";
                  final snackBar = ui.getSnackbar(snackBarMessage);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
                Navigator.pop(context); // Close the dialog box
              },
              child: const Text('Remove'),
            ),
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
                setState(() {
                  credsData[_index] = [id, password];
                });

                updateCredsFile(credsData);

                // Close the dialog box
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: const [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DataTable(
              columns: const [
                DataColumn(label: Text('Net ID')),
                DataColumn(label: Text('Password')),
                DataColumn(label: Text('     ')),
              ],
              rows: credsData
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataRow(
                      cells: [
                        DataCell(Text(entry.value[0])),
                        DataCell(
                          Text(entry.value[1] == '*******'
                              ? '*******'
                              : '*******'),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editCredsDialog(context, entry.key);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddIDDialog(context);
        },
        tooltip: 'Add ID',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
