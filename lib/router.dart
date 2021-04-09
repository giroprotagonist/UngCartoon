import 'package:flutter/material.dart';
import 'package:rideyrbiketracker/widget/authen.dart';
import 'package:rideyrbiketracker/widget/my_service.dart';
import 'package:rideyrbiketracker/widget/register.dart';

final Map<String, WidgetBuilder> routes = {
  '/authen': (BuildContext context) => Authen(),
  '/register': (BuildContext context) => Register(),
  '/myService': (BuildContext context) => MyService(),
};
