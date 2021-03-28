import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ungcartoon/utility/my_style.dart';
import 'package:ungcartoon/widget/information_login.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  String? name, email;
  Widget currentWidget = Information();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findNameAnEmail();
  }

  Future<Null> findNameAnEmail() async {
    await Firebase.initializeApp().then((value) async {
      FirebaseAuth.instance.authStateChanges().listen((event) {
        setState(() {
          name = event!.displayName;
          email = event!.email;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().primaryColor,
      ),
      drawer: buildDrawer(),
      body: currentWidget,
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Stack(
        children: [
          Column(
            children: [
              buildUserAccountsDrawerHeader(),
              buildListTileShowCartoonList(),
              buildListTileInformation(),
            ],
          ),
          buildSignOut(),
        ],
      ),
    );
  }

  ListTile buildListTileShowCartoonList() {
    return ListTile(
      leading: Icon(
        Icons.face,
        size: 36,
      ),
      title: Text('Show Cartoon List'),
      subtitle: Text('Show All Cartoon in my Stock'),
      onTap: () {
        setState(() {
          currentWidget = Information();
        });
        Navigator.pop(context);
      },
    );
  }

  ListTile buildListTileInformation() {
    return ListTile(
      leading: Icon(
        Icons.perm_device_info,
        size: 36,
      ),
      title: Text('Information'),
      subtitle: Text('Information of User Login'),
      onTap: () {
        setState(() {
          currentWidget = Information();
        });
        Navigator.pop(context);
      },
    );
  }

  UserAccountsDrawerHeader buildUserAccountsDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/wall.jpg'), fit: BoxFit.cover),
      ),
      accountName: MyStyle().titleH2White(name == null ? 'Name' : name!),
      accountEmail: MyStyle().titleH3(email == null ? 'email' : email!),
      currentAccountPicture: Image.asset('images/logo.png'),
    );
  }

  Column buildSignOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ListTile(
          onTap: () async {
            await Firebase.initializeApp().then((value) async {
              await FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/authen', (route) => false));
            });
          },
          tileColor: MyStyle().darkColor,
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.white,
            size: 36,
          ),
          title: MyStyle().titleH2White('Sign Out'),
          subtitle: MyStyle().titleH3White('Sign Out & Go to Authen'),
        ),
      ],
    );
  }
}
