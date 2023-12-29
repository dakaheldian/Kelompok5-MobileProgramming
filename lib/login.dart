import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/home.dart';
import 'package:klp5_mp/register.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Username',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      style: TextStyle(
                        color: Colors
                            .white, // Set the text color for the entered text
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      style: TextStyle(
                        color: Colors
                            .white, // Set the text color for the entered text
                      ),
                      cursorColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't you have an account?"),
                TextButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                await login();
              },
              child: Container(
                height: 60,
                width: 140,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      var response = await http.post(Uri.parse(ApiConnect.login), body: {
        "username": usernameController.text,
        "password": passwordController.text,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> user = jsonDecode(response.body);
        print(response.body);

        if (user['success'] == true) {
          final int userId = user['data']['userId'];
          print(user);

          // Coba menyimpan ID user ke dalam session manager
          bool saveSuccess = await saveUserId(userId);

          if (saveSuccess) {
            // Jika penyimpanan berhasil, lanjutkan dengan navigasi
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            // Print hasil setelah berhasil menyimpan ke session manager
            print("User ID berhasil disimpan di SharedPreferences: $userId");
          } else {
            // Handle penyimpanan gagal jika diperlukan
            print("Failed to save user_id to SharedPreferences");
          }
        }
      } else {
        // Handle response status code other than 200
      }
    } catch (e) {
      print("Error during login: $e");
    }
  }

  Future<bool> saveUserId(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      return true; // Penyimpanan berhasil
    } catch (e) {
      print("Error saving user_id to SharedPreferences: $e");
      return false; // Penyimpanan gagal
    }
  }
}
