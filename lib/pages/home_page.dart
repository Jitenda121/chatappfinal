import 'package:chat_app1/modals/ChatRoomModal.dart';
import 'package:chat_app1/modals/firebasehelper.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/ChatRoomPage.dart';
import 'package:chat_app1/pages/SearchPage.dart';
import 'package:chat_app1/pages/login.dart';
import 'package:chat_app1/pages/owner_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModal userModal;
  final User firebaseUser;
  ChatRoomModel? chatroom;

  HomePage(
      {super.key,
      required this.userModal,
      required this.firebaseUser,
      this.chatroom});
  //const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  // void initState() {
  //   super.initState();
  //   markMessagesAsSeen(widget.chatroom, widget.userModal);
  // }

  // void markMessagesAsSeen(ChatRoomModel? chatroom, UserModal userModal) async {
  //   // Similar logic as in ChatRoomPage to mark messages as seen
  //   QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .doc(widget.chatroom!.chatroomid)
  //       .collection("messages")
  //       .where("sender", isNotEqualTo: widget.userModal.uid)
  //       .where("seen", isEqualTo: false)
  //       .get();

  //   for (QueryDocumentSnapshot messageSnapshot in messagesSnapshot.docs) {
  //     await messageSnapshot.reference.update({"seen": true});
  //   }

  //   // Use setState if you need to update local state variables after marking messages as seen
  //   setState(() {
  //     // Update your local variables or state properties if needed
  //   });
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Chat App"), actions: [
        //IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
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
        //   IconButton(onPressed: (

        //   ) {}, icon: Icon(Icons.more_vert)),
        // ],
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // title: Text("Setting"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add options or actions you want in the dialog
                      ListTile(
                        title: Text(
                          "New group",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          // Handle Option 1
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ListTile(
                        title: Text(
                          "New broadcast",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Linked devices",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Starred messages",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Payment",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Setting",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // Handle Option 2
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OwnerProfile(
                                        userModal: widget.userModal,
                                        firebaseUser: widget.firebaseUser,
                                      ))); // Close the dialog
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: Icon(Icons.more_vert),
        )
      ]),
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
                                   // markMessageAsSeen(chatRoomModel,);
                                  // markMessagesAsSeen(
                                  //     widget.chatroom, widget.userModal);
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
  // Future<void> markMessageAsUnseen(MessageModel message) async {
  //    if (chatroom != null && message.seen && message.sender != widget.userModal.uid) {
   
  //   // if (message.seen && message.sender != widget.userModal.uid) {
  //     // Update the 'seen' field of the specific message in Firestore
  //     await FirebaseFirestore.instance
  //         .collection("chatrooms")
  //         .doc(widget.chatroom!.chatroomid)
  //         .collection("messages")
  //         .doc(message.messageid)
  //         .update({"seen": false});
  //   }
  // }
  // Future<void> markMessageAsSeen(message) async {
  //    if (message!= null && message.seen && message.sender != widget.userModal.uid) {
  //     await FirebaseFirestore.instance
  //         .collection("chatrooms")
  //         .doc(widget.chatroom)
  //         .collection("messages")
  //         .doc(message.messageid)
  //         .update({"seen": true});
  //   }
  // }
}
