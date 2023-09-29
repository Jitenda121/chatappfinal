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
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assests/download.jpeg"),
                SizedBox(
                  height: 50,
                ),
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
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email Address"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
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
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => madara()));
                    },
                    child: Text(" OR Login with OTP")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await signInWithGoogle();
                      },
                      child: Image.asset(
                        "assests/download.png",
                        width: 50,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await signInWithFacebook();
                      },
                      child: Icon(
                        Icons.facebook,
                        size: 50,
                        color: Colors.blue,
                      ),
                    )
                  ],
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
              "Don't have a account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                })
          ],
        ),
      ),
    );
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage(
              userModal: UserModal(), firebaseUser: userCredential.user!);
        }));
        debugPrint("Sign in with Facebook failed: ${e.toString()}");
      }
    } catch (e) {
      // Handle and display the error to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sign in with Facebook failed: ${e.toString()}"),
        duration: const Duration(seconds: 10),
      )
          // debugPrint("Sign in with Facebook failed: ${e.toString()}");
          );
    }
  }
  // Future<void> signInWithFacebook() async {
  //   try {
  //     // setState(() {
  //     //   _isSigningIn = true; // Set signing in flag
  //     // });

  //     final LoginResult loginResult = await FacebookAuth.instance.login();
  //     final OAuthCredential facebookAuthCredential =
  //         FacebookAuthProvider.credential(loginResult.accessToken!.token);
  //     final UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithCredential(facebookAuthCredential);

  //     if (context.mounted) {
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const PostScreen()));
  //     }
  //   } catch (e) {
  //     // Handle and display the error to the user
  //     // ignore: use_build_context_synchronously
  //     //debugPrint("Sign in with Facebook failed: ${e.toString()}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Sign in with Facebook failed: ${e.toString()}"),
  //         duration: const Duration(seconds: 60),
  //       ),
  //     );
  //     debugPrint("Sign in with Facebook failed: ${e.toString()}");
  //   }
  //   // finally {
  //   //   // setState(() {
  //   //   //   _isSigningIn = false;
  //   //   //   // Reset signing in flag
  //   //   // });
  //   // }
  // }

  // Future<void> signInwithGoogle() async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;
  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  //   // ignore: unused_local_variable
  //   final UserCredential userCredential =
  //       await _auth.signInWithCredential(credential);
  // }
  Future<void> signInWithGoogle() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // You can access the signed-in user using userCredential.user
      User? user = userCredential.user;

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(userModal: UserModal(), firebaseUser: user!);
        },
      ));

      // Handle the successful sign-in here
      // For example, you can show a success message or navigate to a new screen.
    } catch (e) {
      // Handle the error here
      //debugPrint("Sign in with Google failed: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in with Google failed: ${e.toString()}"),
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint("Sign in with Google failed: ${e.toString()}");
    }
  }
}
