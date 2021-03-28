import 'package:flutter/material.dart';
import 'package:ungcartoon/widget/authen.dart';
import 'package:ungcartoon/widget/my_service.dart';
import 'package:ungcartoon/widget/register.dart';

final Map<String, WidgetBuilder> routes = {
  '/authen': (BuildContext context) => Authen(),
  '/register': (BuildContext context) => Register(),
  '/myService': (BuildContext context) => MyService(),
};
