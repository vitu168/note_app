import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'appcolor.dart' as Colortheme;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colortheme.background,
      appBar: AppBar(
        backgroundColor: Colortheme.primary,
        leadingWidth: 60,
        toolbarHeight: 40,
        leading: Container(
          margin: const EdgeInsets.only(left: 20),
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colortheme.background),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colortheme.background,
              size: 20,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colortheme.background,
                    border: Border.all(color: Colortheme.success)),
                child: Image.asset(width: 80, 'assets/images.png'),
              ),
            ),
          ),
          const Text(
            "Login",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Text(
            "Login to continue using the app",
            style: TextStyle(fontSize: 15, color: Colortheme.info),
          ),
          const Text(
            "Email",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          const TextField(
            decoration: InputDecoration(
                filled: true,
                focusColor: Colortheme.darkGrey,
                fillColor: Color.fromARGB(255, 22, 22, 175),
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                )),
          )
        ],
      ),
    );
  }
}
