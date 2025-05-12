import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kitchen_king/common/custom_textfield.dart';
import 'package:kitchen_king/features/authentication/form_screen.dart';
import 'package:kitchen_king/features/authentication/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register-screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
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
                "Let's, Get \nStarted",
                style: TextStyle(
                  fontSize: 50,
                  color: Color(0xFF45484A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .18),
              CustomInputField(
                hintText: 'Enter email',
                labelText: 'Email',
                controller: _emailController,
                icon: Icons.email,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomInputField(
                hintText: 'Enter strong password',
                labelText: 'Password',
                isPassword: true,
                controller: _passwordController,
                icon: Icons.password,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
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
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      if (kDebugMode) {
                        print(userCredential.user.toString());
                        print(userCredential.credential.toString());
                      }
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pushReplacementNamed(
                        context,
                        FormScreen.routeName,
                      );
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (kDebugMode) {
                        print("Error during registration: $e");
                      }
                      Fluttertoast.showToast(
                        msg: "Something went wrong during registration",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account!!",
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
                        LoginScreen.routeName,
                      );
                    },
                    child: const Text(
                      "Login",
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
