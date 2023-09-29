import 'package:chat_app1/pages/verifyphonenumber.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class madara extends StatefulWidget {
  const madara({super.key});

  @override
  State<madara> createState() => _madaraState();
}

class _madaraState extends State<madara> {
  bool loading = false;
  final phonenumbercontroller = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("phone"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: phonenumbercontroller,
                decoration: InputDecoration(hintText: "+91 7666687901"),
              ),
              SizedBox(height: 50),
              Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        loading;
                        setState(() {
                          loading = true;
                        });
                        auth.verifyPhoneNumber(
                            phoneNumber: phonenumbercontroller.text,
                            verificationCompleted: (_) {},
                            verificationFailed: (FirebaseAuthException e) {
                              setState(() {
                                loading = false;
                              });
                            },
                            codeSent: (String verificatonId, int? resendToken) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => obito(
                                            verifactionId: verificatonId,
                                          )));
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {
                              setState(() {
                                loading = false;
                              });
                            });
                      },
                      child: Text("login")))
            ],
          ),
        ),
      ),
    );
  }
}