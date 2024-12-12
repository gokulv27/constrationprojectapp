import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'pages/login_page.dart';
import 'pages/dashboard.dart';
import 'pages/labor_page.dart';
import 'pages/add_labor_page.dart';
import 'pages/project_list_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labor Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: FadeIn(
        duration: const Duration(milliseconds: 1000),
        child: const LoginPage(),
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/labor_management': (context) => const LaborPage(),
        '/add_labor': (context) => const AddLaborPage(),
        '/projects': (context) => const ProjectPage(),
         // New route
      },
    );
  }
}

