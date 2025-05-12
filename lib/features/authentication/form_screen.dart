import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_king/common/custom_textfield.dart';
import 'package:kitchen_king/features/home/home.dart';

class FormScreen extends StatefulWidget {
  static const String routeName = '/from-screen';
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noOfFamiliyMember = TextEditingController();
  final TextEditingController _cookingFrequency = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveDataToFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      // Create a data map
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'family_members': int.tryParse(_noOfFamiliyMember.text) ?? 0,
        'cooking_frequency': int.tryParse(_cookingFrequency.text) ?? 0,
        'home': _houseController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip_code': _zipCodeController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: height * .05),
              const Text(
                "Enter Personal Details",
                style: TextStyle(
                  fontSize: 50,
                  color: Color(0xFF45484A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .05),
              CustomInputField(
                labelText: "Name",
                hintText: "Enter your full name",
                icon: Icons.person_outline_outlined,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'Enter your mobile no',
                labelText: 'Mobile Number',
                type: TextInputType.number,
                controller: _mobileController,
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'Enter number of family members (e.g. 2, 3....)',
                labelText: 'Family Members',
                type: TextInputType.number,
                controller: _noOfFamiliyMember,
                icon: Icons.family_restroom_outlined,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'Weekly frequency of cooking (e.g. 10, 17....)',
                labelText: 'Cooking Frequency',
                type: TextInputType.number,
                controller: _cookingFrequency,
                icon: Icons.restaurant,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'Flat/ House no/ Building name',
                labelText: 'Home',
                controller: _houseController,
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'City',
                labelText: 'City',
                controller: _cityController,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'State',
                labelText: 'State',
                controller: _stateController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              CustomInputField(
                hintText: 'Zip Code',
                labelText: 'Zip Code',
                type: TextInputType.number,
                controller: _zipCodeController,
                icon: Icons.markunread_mailbox_outlined,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: _saveDataToFirestore,
        child: Container(
          height: 65,
          width: 65,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF45484A),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10, // Soft shadow
                spreadRadius: 2,
                offset: Offset(3, 5), // Adds depth
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
