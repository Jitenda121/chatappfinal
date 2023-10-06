import 'dart:developer';
import 'package:chat_app1/main.dart';
import 'package:chat_app1/modals/ChatRoomModal.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        }, users: [],
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
        title: Text(
          "Search",
          style: TextStyle(fontSize: 26),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 31, 55),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              TextField(
                
                controller: searchController,

                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search),
                    labelText: "Full Name"),
                //decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: const Color.fromARGB(255, 2, 31, 55),
                child: Text(
                  "Search",
                  style: TextStyle(fontSize: 20),
                ),
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

                          return Card(
                            elevation: 4, // Add elevation for a shadow effect
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
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
                            ),
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
