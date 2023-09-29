// import 'dart:developer';
// import 'package:chat_app1/main.dart';
// import 'package:chat_app1/modals/ChatRoomModal.dart';
// import 'package:chat_app1/modals/userModals.dart';
// import 'package:chat_app1/pages/ChatRoomPage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter_application_1/main.dart';
// //import 'package:flutter_application_1/modals/ChatRoomModal.dart';
// //import 'package:flutter_application_1/modals/userModals.dart';
// //import 'package:flutter_application_1/pages/ChatRoomPage.dart';
// //import 'package:uuid/uuid.dart';

// class SearchPage extends StatefulWidget {
//   final UserModal userModal;
//   final User firebaseUser;

//   const SearchPage(
//       {super.key, required this.userModal, required this.firebaseUser});

//   //const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   TextEditingController searchController = TextEditingController();
//   Future<ChatRoomModel?> getChatroomModel(UserModal targetUser) async {
//     ChatRoomModel? chatRoom;
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .where("participants.${widget.userModal.uid}", isEqualTo: true)
//         .where("participants.${targetUser.uid}", isEqualTo: true)
//         .get();

//     if (snapshot.docs.length > 0) {
// //fetching the existing one
//       //log("chatroom already created!");
//       var docData = snapshot.docs[0].data();
//       ChatRoomModel existingChatroom =
//           ChatRoomModel.fromMap(docData as Map<String, dynamic>);
//       chatRoom = existingChatroom;
//     } else {
// //create a new one
//       ChatRoomModel newChatroom = ChatRoomModel(
//         chatroomid: uuid.v1(),
//         lastMessage: "",
//         participants: {
//           widget.userModal.uid.toString(): true,
//           targetUser.uid.toString(): true
//         },
//         // chatroomid: uuid.v1(),
//         //lastMessage: "",
//       );
//       await FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(newChatroom.chatroomid)
//           .set(newChatroom.toMap());
//       chatRoom = newChatroom;
//       log("new chatroom created!");
//       //log("chatroom not created! ");
//     }
//     return chatRoom;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Search"),
//       ),
//       body: SafeArea(
//           child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           children: [
//             TextField(
//               onChanged: (value) {
//                 setState(() {});
//               },
//               controller: searchController,
//               decoration: InputDecoration(labelText: "Full Name"),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             CupertinoButton(
//               onPressed: () {
//                 setState(() {});
//               },
//               color: Theme.of(context).colorScheme.secondary,
//               child: Text("Search"),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection("users")
//                     .orderBy("fullname")
//                     .startAt([searchController.text]).endAt(
//                         [searchController.text])
//                     // .where("fullname", isEqualTo: searchController.text)
//                     // .where("fullname", isNotEqualTo: widget.userModal.email)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.active) {
//                     if (snapshot.hasData) {
//                       QuerySnapshot dataSnapshot =
//                           snapshot.data as QuerySnapshot;
//                       if (dataSnapshot.docs.length > 0) {
//                         Map<String, dynamic> userMap =
//                             dataSnapshot.docs[0].data() as Map<String, dynamic>;
//                         UserModal searchedUser = UserModal.fromMap(userMap);
//                         return ListTile(
//                           onTap: () async {
//                             ChatRoomModel? chatRoomModel =
//                                 await getChatroomModel(searchedUser);
//                             if (chatRoomModel != null) {
//                               Navigator.pop(context);
//                               Navigator.push(context, MaterialPageRoute(
//                                 builder: (context) {
//                                   return ChatRoomPage(
//                                     targetUser: searchedUser,
//                                     userModal: widget.userModal,
//                                     firebaseUser: widget.firebaseUser,
//                                     chatroom: chatRoomModel,
//                                   );
//                                 },
//                               ));
//                             }

//                             // Navigator.pop(context);
//                             // Navigator.push(context, MaterialPageRoute(
//                             //   builder: (context) {
//                             //     return ChatRoomPage(
//                             //       targetUser: searchedUser,
//                             //       userModal: widget.userModal,
//                             //       firebaseUser: widget.firebaseUser,
//                             //       chatroom: ,
//                             //     );
//                             //   },
//                             // ));
//                           },
//                           leading: CircleAvatar(
//                             backgroundImage:
//                                 NetworkImage(searchedUser.profilepic!),
//                             backgroundColor: Colors.black,
//                           ),
//                           title: Text(searchedUser.fullname!),
//                           subtitle: Text(searchedUser.email!),
//                           trailing: Icon(Icons.keyboard_arrow_right),
//                         );
//                       } else {
//                         return Text("No result found");
//                       }
//                       // Map<String, dynamic> userMap =
//                       //     dataSnapshot.docs[0].data() as Map<String, dynamic>;
//                       // UserModal searchedUser = UserModal.fromMap(userMap);
//                       // return ListTile(
//                       //   title: Text(searchedUser.fullname!),
//                       //   subtitle: Text(searchedUser.email!),
//                       // );
//                     } else if (snapshot.hasError) {
//                       return Text("An error occured!");
//                     } else {
//                       return Text("No result found!");
//                     }
//                   } else {
//                     return CircularProgressIndicator();
//                   }
//                 })
//           ],
//         ),
//       )),
//     );
//   }
// }

import 'dart:developer';
import 'package:chat_app1/main.dart';
import 'package:chat_app1/modals/ChatRoomModal.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:chat/main.dart';
//import 'package:flutter_application_1/modals/ChatRoomModal.dart';
//import 'package:flutter_application_1/modals/userModals.dart';
//import 'package:flutter_application_1/pages/ChatRoomPage.dart';

class SearchPage extends StatefulWidget {
  final UserModal userModal;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModal, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModal targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModal.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModal.uid.toString(): true,
          targetUser.uid.toString(): true
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
      log("new chatroom created!");
    }
    return chatRoom;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Search"),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .orderBy("fullname")
                    .startAt([searchController.text]).endAt(
                        [searchController.text + '\uf8ff']).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return Column(
                        children:
                            dataSnapshot.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> userMap =
                              document.data() as Map<String, dynamic>;
                          UserModal searchedUser = UserModal.fromMap(userMap);

                          // Check if the searched user is the same as the logged-in user
                          if (searchedUser.uid == widget.userModal.uid) {
                            return Container(); // Skip the logged-in user
                          }

                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatRoomModel =
                                  await getChatroomModel(searchedUser);
                              if (chatRoomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      userModal: widget.userModal,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatRoomModel,
                                    );
                                  },
                                ));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searchedUser.profilepic!),
                              backgroundColor: Colors.black,
                            ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(searchedUser.email!),
                            //trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text("An error occurred!");
                    } else {
                      return Text("No result found!");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}