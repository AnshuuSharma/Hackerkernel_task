import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://reqres.in/api/login'),
      body: json.encode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed! Please try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('/login_page.png',width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height*0.4,),

            ),
            Text("Login",style: TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: 23,
                color: Colors.blue[900]),
            ),
            SizedBox(height: 20),
            buildTextField(emailController,'Email',Icons.alternate_email,false),
            SizedBox(height: 20),
            buildTextField(passwordController,'Password',Icons.lock_clock,true),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Center(
                  child: ElevatedButton(
                                onPressed: loginUser,
                                child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white
                    )
                    ),
                ),
          ],
        ),
      ),
    );
  }

  TextField buildTextField(TextEditingController c,String s,IconData i,bool ans) {
    return TextField(
            controller: c,
            obscureText: ans,
            decoration: InputDecoration(
              labelText: s,
              labelStyle: TextStyle(fontSize: 14,color: Colors.blueGrey),
              icon: Icon(i),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey,width: 1), 
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), 
              ),
            )
          );
  }
}
