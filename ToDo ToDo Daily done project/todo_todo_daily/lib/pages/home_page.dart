import 'package:flutter/material.dart';
import 'package:todo_todo_daily/DB_HELPER/sql_helper.dart';

class HomePAge extends StatefulWidget {
  const HomePAge({super.key});

  @override
  State<HomePAge> createState() => _HomePAgeState();
}

class _HomePAgeState extends State<HomePAge> {
  //creat a variables of list of map
  List<Map<String, dynamic>> _journals = [];

  bool _isloading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isloading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
    print(',,,,Number of item ${_journals.length}');
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  //this method for add item
  Future<void> _addItem() async {
    await SQLHelper.creatItem(titleController.text, descController.text);
    _refreshJournals();
    print(',,,,Number of item ${_journals.length}');
  }

  //this method for delete item
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, titleController.text, descController.text);
    _refreshJournals();
  }

  //this method for delete item
  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully deleted a journal!')));
    _refreshJournals();
  }

//this is the first step to show this bottomsheet on floating actionbutton
// this method for bottomsheetform
  void _showForm(int? id) async {
    if (id != null) {
      final existingJournuls =
          _journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournuls['title'];
      descController.text = existingJournuls['desc'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          right: 15,
          left: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: 'Add your todo',
                  hintStyle: TextStyle(
                    fontSize: 20,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Add your Description',
                hintStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }

                //clear the text field
                titleController.text = '';
                descController.text = '';

                //close the bottomsheet
                Navigator.of(context).pop();
              },
              child: Text(
                id == null ? 'Create New' : 'Update',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 248, 229),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ToDo Your\'s'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () => _showForm(null),
      ),
      body: ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.white,
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(
              _journals[index]['title'],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            subtitle: Text(
              _journals[index]['desc'],
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () => _showForm(_journals[index]['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(_journals[index]['id']),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
