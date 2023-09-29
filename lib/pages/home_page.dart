import 'package:chat_app1/modals/ChatRoomModal.dart';
import 'package:chat_app1/modals/firebasehelper.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/ChatRoomPage.dart';
import 'package:chat_app1/pages/SearchPage.dart';
import 'package:chat_app1/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_1/modals/ChatRoomModal.dart';
//import 'package:flutter_application_1/modals/UIHelper.dart';
//import 'package:flutter_application_1/modals/firebasehelper.dart';
//import 'package:flutter_application_1/modals/userModals.dart';
//import 'package:flutter_application_1/pages/ChatRoomPage.dart';
//import 'package:flutter_application_1/pages/SearchPage.dart';
//import 'package:flutter_application_1/pages/login.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  final UserModal userModal;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModal, required this.firebaseUser});
  //const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(centerTitle: true, title: Text("Chat App")),
    //   body: SafeArea(
    //       child: Container(
    //     child: StreamBuilder(
    //       stream: FirebaseFirestore.instance
    //           .collection("chatrooms")
    //           .where("participant.${widget.userModal.uid}", isEqualTo: true)
    //           .snapshots(),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.active) {
    //           if (snapshot.hasData) {
    //             QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
    //             return ListView.builder(
    //                 itemCount: chatRoomSnapshot.docs.length,
    //                 itemBuilder: (context, index) {
    //                   ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
    //                       chatRoomSnapshot.docs[index].data()
    //                           as Map<String, dynamic>);
    //                   Map<String, dynamic> participants =
    //                       chatRoomModel.participants!;
    //                   List<String> participantkeys = participants.keys.toList();
    //                   participantkeys.remove(widget.userModal.uid);
    //                   return FutureBuilder(
    //                     future:
    //                         FirebaseHelper.getUserModalById(participantkeys[0]),
    //                     builder: (context, userData) {
    //                       UserModal targetUser = userData.data as UserModal;
    //                       return ListTile(
    //                         leading: CircleAvatar(
    //                           backgroundImage: NetworkImage(
    //                               targetUser.profilepic.toString()),
    //                         ),
    //                         title: Text(targetUser.fullname.toString()),
    //                         subtitle:
    //                             Text(chatRoomModel.lastMessage.toString()),
    //                       );
    //                     },
    //                   );
    //                 });
    //           } else if (snapshot.hasError) {
    //             return Center(
    //               child: Text(snapshot.error.toString()),
    //             );
    //           } else {
    //             return Center(
    //               child: Text("No Chats"),
    //             );
    //           }
    //         } else {
    //           return Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         }
    //       },
    //     ),
    //   )),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       Navigator.push(context, MaterialPageRoute(
    //         builder: (context) {
    //           return SearchPage(
    //               userModal: widget.userModal,
    //               firebaseUser: widget.firebaseUser);
    //         },
    //       ));
    //     },
    //     child: Icon(Icons.search),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModal.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModal.uid);
                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModalById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModal targetUser = userData.data as UserModal;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModal: widget.userModal,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                leading: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Center(
                                            child: Container(
                                                width: 300,
                                                height: 300,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,

                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                        targetUser.profilepic
                                                            .toString(),
                                                      )),
                                                  // child: CircleAvatar(
                                                  //   //radius: 5,
                                                  //   backgroundImage: NetworkImage(
                                                  //     targetUser.profilepic
                                                  //         .toString(),
                                                  //   ),
                                                  // ),
                                                )),
                                          );
                                        });
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                ),
                                title: Text(targetUser.fullname.toString()),
                                subtitle: (chatRoomModel.lastMessage
                                            .toString() !=
                                        "")
                                    ? Text(chatRoomModel.lastMessage.toString())
                                    : Text(
                                        "Say hi to your new friend!",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModal: widget.userModal, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
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
}
