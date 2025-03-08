import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kitchen_king/common/bottom_bar.dart';
import 'package:kitchen_king/common/custom_textfield.dart';
import 'package:kitchen_king/features/authentication/register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * .05),
              const Text(
                "Hey, \nWelcome \nBack",
                style: TextStyle(
                  fontSize: 50,
                  color: Color(0xFF45484A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .18),
              CustomInputField(
                hintText: 'Email',
                labelText: 'Email',
                controller: _emailController,
                icon: Icons.email,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomInputField(
                hintText: 'Password',
                labelText: 'Password',
                isPassword: true,
                controller: _passwordController,
                icon: Icons.password,
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  height: 60,
                  width: width * .9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF45484A),
                      foregroundColor: const Color(0xFF45484A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      )
                          .then((value) {
                        if (kDebugMode) {
                          print("New Account Created");
                        }
                        Navigator.pushNamed(
                          context,
                          BottomBar.routeName,
                        );
                      }).onError((error, stackTrace) {
                        Fluttertoast.showToast(
                          msg: "Incorrect combination of email and password",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      });
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 3),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RegisterScreen.routeName,
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 92, 90, 90),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
