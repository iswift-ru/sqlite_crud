import 'package:flutter/material.dart';
import 'package:sqlitecrud/dbmanager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SQLite CRUD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbStudentManager dbmaneger = DbStudentManager();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Student student;
  List<Student> studlist;
  int updateIndex;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Name Should Not Be Empty',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Course'),
                    controller: _courseController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Name Should Not Be Empty',
                  ),
                ),
                RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blueAccent,
                  child: Container(
                    width: width * 0.9,
                    child: Text(
                      'Submit',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _submitStudent(context);
                    });
                  },
                ),
                FutureBuilder(
                  future: dbmaneger.getStudentList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      studlist = snapshot.data;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            studlist.length == null ? 0 : studlist.length,
                        itemBuilder: (BuildContext context, int index) {
                          Student st = studlist[index];
                          return Card(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: width * 0.60,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Name: ${st.name}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54),
                                      ),
                                      Text('Course: ${st.course}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _nameController.text = st.name;
                                    _courseController.text = st.course;
                                    student = st;
                                    updateIndex = index;
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    dbmaneger.deleteStudent(st.id);
                                    setState(() {
                                      studlist.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return CircularProgressIndicator();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _submitStudent(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (student == null) {
        Student st =
            Student(name: _nameController.text, course: _courseController.text);
        dbmaneger.insertStudents(st).then((id) => {
              _nameController.clear(),
              _courseController.clear(),
              print('Student add to db $id')
            });
      } else {
        student.name = _nameController.text;
        student.course = _courseController.text;
        dbmaneger.updateStudent(student).then((id) => {
              setState(() {
                studlist[updateIndex].name = _nameController.text;
                studlist[updateIndex].course = _courseController.text;
              }),
              _nameController.clear(),
              _courseController.clear()
            });
      }
    }
  }
}
