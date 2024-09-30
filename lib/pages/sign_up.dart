import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resoluteai/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _email, _password, _name, _age, _phoneNumber;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickAndStoreImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _storeImageInPrefs(pickedFile.path);
    }
  }

  Future<void> _storeImageInPrefs(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  Future<void> _storeUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name!);
    await prefs.setString('age', _age!);
    await prefs.setString('phone_number', _phoneNumber!);
    await prefs.setString('email', _email!);
  }

  Future<void> _signupUser() async {
    if (_formKey.currentState!.validate()) {
      FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      try {
        if (_profileImage != null) {
          // Sign up logic here
          UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );

          // Store user information in SharedPreferences
          await _storeUserInfo();

          // Display success dialog after signup
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Icon(Icons.check_circle, color: Colors.green, size: 50),
              content: Text('Account created successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Handle if no profile image is selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a profile image')),
          );
        }
      } catch (e) {
        print("Error signing up: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAndStoreImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) => _name = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _age = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _phoneNumber = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => _email = value,
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (value) => _password = value,
                  validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signupUser,
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
