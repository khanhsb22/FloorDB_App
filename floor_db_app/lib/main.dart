import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/person_dao.dart';
import 'package:flutter_app/person_entity.dart';

void main() {
  runApp(MaterialApp(
    title: "MyApp",
    home: MyStateFulWidget(),
  ));
}

class MyStateFulWidget extends StatefulWidget {
  @override
  _MyStateFulWidgetState createState() => _MyStateFulWidgetState();
}

class _MyStateFulWidgetState extends State<MyStateFulWidget> {
  PersonDao? personDao;
  List<Person> list = <Person>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('my_database.db').build();
    personDao = database.personDao;
    // Get all data when start app.
    if (personDao != null) {
      setState(() {
        isLoading = true;
      });
      list = await getAllData();
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Person>> getAllData() async {
    var result = await personDao!.getAllPeople();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(
            top: 25.0,
            left: 16.0,
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      "FloorDB sample",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteAllDialog(context);
                        },
                        iconSize: 25,
                        color: Colors.white,
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                        // shrinkWrap attribute is required when adding listview to Column
                        shrinkWrap: true,
                        // This attribute additional for SingleChildScrollView
                        physics: ScrollPhysics(parent: null),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          //return PersonItem(list[index], this.personDao, this.list, index);
                          return _personItem(list[index], context, index);
                        })
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => _showAddPersonDialog(context));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("Delete all item"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text("Do you want remove all record ?")],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    personDao!.deleteAllPerson();
                    setState(() {
                      list.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "No",
                    style: TextStyle(color: Colors.pink),
                  ))
            ],
          );
        });
  }

  Widget _personItem(Person person, BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => _showUpdatePersonDialog(
                person.id!, person.name, person.age, context, index));
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: 100,
        child: Card(
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40.0,
              ),
              Text(
                "Name: " + person.name.toString(),
                style: TextStyle(fontSize: 15.0),
              ),
              SizedBox(
                width: 40.0,
              ),
              Text(
                "Age: " + person.age.toString(),
                style: TextStyle(fontSize: 15.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showUpdatePersonDialog(
      int id, String name, String age, BuildContext context, int index) {
    var nameController = TextEditingController(text: name);
    var ageController = TextEditingController(text: age);

    return Dialog(
      // This attribute to set maximum width for dialog.
      insetPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: 300.0,
        width: 400.0,
        child: Column(
          children: [
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "View person",
                style: TextStyle(fontSize: 18.0, color: Colors.blue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Enter a name", border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: ageController,
                decoration: InputDecoration(
                    hintText: "Enter age", border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150.0,
                  child: ElevatedButton(
                      onPressed: () async {
                        // Update 1 person.
                        await personDao!.updatePerson(
                            id, nameController.text, ageController.text);
                        setState(() {
                          list[index].name = nameController.text;
                          list[index].age = ageController.text;
                        });
                        // Dismiss dialog.
                        Navigator.of(context).pop();
                      },
                      child: Text("Update",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                              //to set border radius to button
                              borderRadius: BorderRadius.circular(15)),
                          padding:
                              EdgeInsets.all(20) //content padding inside button
                          )),
                ),
                SizedBox(
                  width: 150.0,
                  child: ElevatedButton(
                      onPressed: () async {
                        // Delete 1 person.
                        await personDao!.deleteOnePerson(id);
                        setState(() {
                          var item = this
                              .list
                              .firstWhere((element) => element.id == id);
                          list.remove(item);
                        });
                        // Dismiss dialog.
                        Navigator.of(context).pop();
                      },
                      child: Text("Delete",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shape: RoundedRectangleBorder(
                              // To set border radius to button.
                              borderRadius: BorderRadius.circular(15)),
                          padding:
                              EdgeInsets.all(20) //content padding inside button
                          )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _showAddPersonDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();

    return Dialog(
      // This attribute to set maximum width for dialog.
      insetPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: 300.0,
        width: 400.0,
        child: Column(
          children: [
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Add new person",
                style: TextStyle(fontSize: 18.0, color: Colors.blue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Enter a name", border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: ageController,
                decoration: InputDecoration(
                    hintText: "Enter age", border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            SizedBox(
              width: double.infinity, // Stretch the button to its full length.
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      // Add 1 person.
                      final person =
                          Person(null, nameController.text, ageController.text);
                      await personDao!.insertPerson(person);
                      setState(() {
                        // Refresh list.
                        var id = (list.last.id);
                        list.add(Person(
                            id! + 1, nameController.text, ageController.text));
                      });
                      // Dismiss dialog.
                      Navigator.of(context).pop();
                    },
                    child: Text("Add",
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                            //to set border radius to button
                            borderRadius: BorderRadius.circular(15)),
                        padding:
                            EdgeInsets.all(20) //content padding inside button
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
