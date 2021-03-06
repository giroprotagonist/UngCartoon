import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rideyrbiketracker/utility/my_style.dart';
import 'package:rideyrbiketracker/widget/backgroundbetch.dart';
import 'package:rideyrbiketracker/widget/add_location.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  late String name, email;
  Widget currentWidget = BackgroundBetcher();

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
          name = event!.displayName!;
          email = event.email!;
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
      title: Text('Manual Location Update'),
      subtitle: Text('Send a single location update'),
      onTap: () {
        setState(() {
          currentWidget = PageWidget();
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
      title: Text('Background Location Fetch Log'),
      subtitle: Text('History of recorded locations'),
      onTap: () {
        setState(() {
          currentWidget = BackgroundBetcher();
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
      accountName: MyStyle().titleH2White(name),
      accountEmail: MyStyle().titleH3(email),
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
