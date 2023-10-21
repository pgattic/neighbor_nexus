import 'package:flutter/material.dart';

class User {
  var id;
  var name;
  var email;
  var adress;
  User({this.id, this.name, this.email, this.adress});
}

var user = User(
  id: '123',
  name: 'John Doe',
  email: 'john.doe@example.com',
  adress: '123 Main St',
);

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User page'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Update Profile Picture'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Name: ${user.name}'),
              SizedBox(height: 20),
              Text('Email: ${user.email}'),
              SizedBox(height: 20),
              Text('Address: ${user.adress}'),
            ],
          ),
        ),
      ),
    );
  }
}
