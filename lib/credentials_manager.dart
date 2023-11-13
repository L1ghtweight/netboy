import 'package:flutter/material.dart';
import 'file_io_handler.dart';

class CredentialsManager extends StatefulWidget {
  const CredentialsManager({super.key, required this.title});

  final String title;

  @override
  State<CredentialsManager> createState() => _CredentialsManagerState();
}

class _CredentialsManagerState extends State<CredentialsManager> {
  List<List<String>> data = getCredsData() as List<List<String>>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            tooltip: 'Edit',
            onPressed: () {
              // Add button functionality here
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DataTable(
              columns: [
                DataColumn(label: Text('Net ID')),
                DataColumn(label: Text('Password')),
                DataColumn(label: Text('     ')),
              ],
              rows: data
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataRow(
                      cells: [
                        DataCell(Text(entry.value[0])),
                        DataCell(Text(entry.value[1])),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit button click
                              // Pass the index of the pressed row
                              print(entry.key);
                              print(data[entry.key]);
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
