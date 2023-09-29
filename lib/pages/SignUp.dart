import 'package:chat_app1/modals/UIHelper.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/completeprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      // print("Please fill all the fields!");
      UIHelper.showAlertDialog(
          context, "Incomplete fields ", "please Fill the fields");
    } else if (password != cPassword) {
      //  print("Password do not match!");
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The Passwords you entered do not match!");
    } else {
      signUp(email, password);
      // print("Sign Up Successful!");
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating  new account");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
      //print(ex.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModal newUser = UserModal(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created!");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModal: newUser, firebaseUser: credential!.user!);
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Chat App",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email Address"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: cPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: " Confirm Password"),
                ),
                SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  child: Text("Sign Up"),
                  onPressed: () {
                    checkValues();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CompleteProfile()));
                  },
                  color: Theme.of(context).colorScheme.secondary,
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
                child: Text(
                  "Login In",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
