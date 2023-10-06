import 'dart:math';
import 'dart:ui';
import 'package:chat_app1/modals/UIHelper.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/SignUp.dart';
import 'package:chat_app1/pages/home_page.dart';
import 'package:chat_app1/pages/loginwithphone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
      print("Please fill all the!");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Logging In");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "an error", ex.message.toString());
      print(ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModal userModal =
          UserModal.fromMap(userData.data() as Map<String, dynamic>);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(
              userModal: userModal, firebaseUser: credential!.user!);
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            // image:
            //     DecorationImage(image: AssetImage("assests/Rectangle 1.png")
            // )
            image: DecorationImage(
                image: NetworkImage(
                    "https://i.pinimg.com/564x/1d/4e/4d/1d4e4d6bc5aeadcac5830d32636d3256.jpg"),
                fit: BoxFit.fill)),
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image.asset("assests/download.jpeg"),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Chat App",
                  style: TextStyle(
                      color: Color.fromARGB(255, 10, 123, 214),
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
          
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Password"),
                ),
                SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  child: Text("Login In"),
                  onPressed: () {
                    checkValues();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have a account?",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      CupertinoButton(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                          })
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
