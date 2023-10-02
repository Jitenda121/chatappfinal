import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app1/main.dart';
import 'package:chat_app1/modals/userModals.dart';
import 'package:chat_app1/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../modals/ChatRoomModal.dart';
import '../modals/Messagemodel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModal targetUser;
  final ChatRoomModel chatroom;
  final UserModal userModal;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModal,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      DateTime currentDateTime = DateTime.now();
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.targetUser.uid,
        createdon: currentDateTime,
        text: msg,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("send message!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => User_Profile(
                          userModal: widget.userModal,
                          targetUser: widget.targetUser,
                        )));
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage:
                    NetworkImage(widget.targetUser.profilepic.toString()),
                child: GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(widget.targetUser.fullname.toString()),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          clearChat();
                          //Navigator.pop(context); // Close the dialog
                        },
                        child: Text(
                          'Clear Chat',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Container(
        //color: Colors.grey[300],
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>,
                            );

                            //convert it to createon to dateformat
                            String formattedTime = DateFormat('hh:mm a')
                                .format(currentMessage.createdon);
                            return Dismissible(
                              key: UniqueKey(),
                              background: Container(
                                color: Colors.red,
                                child: Align(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              onDismissed: (direction) async {
                                if (direction == DismissDirection.startToEnd &&
                                    currentMessage.sender !=
                                        widget.userModal.uid) {
                                  DocumentReference chatRoomRef =
                                      FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .doc(widget.chatroom.chatroomid);

                                  // Delete a message (you might have implemented this already)
                                  await FirebaseFirestore.instance
                                      .collection("chatrooms")
                                      .doc(widget.chatroom.chatroomid)
                                      .collection("messages")
                                      .doc(currentMessage.messageid)
                                      .delete();

                                  // Fetch the remaining messages and get the latest one
                                  QuerySnapshot messagesSnapshot =
                                      await chatRoomRef
                                          .collection("messages")
                                          .orderBy("createdon",
                                              descending: true)
                                          .get();

                                  if (messagesSnapshot.docs.isNotEmpty) {
                                    // Get the latest message after deletion
                                    String latestMessage =
                                        messagesSnapshot.docs.first["text"];

                                    // Update the lastMessage field of the chat room

                                    await FirebaseFirestore.instance
                                        .collection("chatrooms")
                                        .doc(widget.chatroom.chatroomid)
                                        .set({"lastmessage": latestMessage},
                                            SetOptions(merge: true));
                                  } else {
                                    // If there are no remaining messages, you can set lastMessage to an empty string or a default value.
                                    await chatRoomRef.update({
                                      "lastmessage": "",
                                    });
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Message deleted'),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: (currentMessage.sender ==
                                        widget.userModal.uid)
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  //Icon(Icons.done_all),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModal.uid)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Color.fromARGB(255, 108, 219, 112),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                    // child: Text(
                                    //   currentMessage.text.toString(),
                                    //   formattatedTime,
                                    //   style: TextStyle(color: Colors.black),
                                    // ),
                                    // Text(
                                    //   formattedTime,
                                    //   style: TextStyle(color: Colors.grey),
                                    // ),

                                    //Displaying timestamp with text
                                    //if(currentmessage.sender==widget.user)
                                    //Icon:()

                                    child: Row(
                                      children: [
                                        Text(
                                          '${currentMessage.text.toString()} - $formattedTime',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        if (currentMessage.sender !=
                                            widget.userModal.uid)
                                          Icon(
                                            Icons.done_all,
                                            color: const Color.fromARGB(
                                                255, 4, 53, 93),
                                          ),
                                      ],
                                    ),
                                  ),
                                  //Icon(Icons.done_all)
                                ],
                              ),
                            );
                          },
                        );

                        // ListView.builder(
                        //     reverse: true,
                        //     itemCount: dataSnapshot.docs.length,
                        //     itemBuilder: (context, index) {
                        //       MessageModel currentMessage =
                        //           MessageModel.fromMap(dataSnapshot.docs[index]
                        //               .data() as Map<String, dynamic>);
                        //       return Row(
                        //         mainAxisAlignment: (currentMessage.sender ==
                        //                 widget.userModal.uid)
                        //             ? MainAxisAlignment.start
                        //             : MainAxisAlignment.end,
                        //         children: [
                        //           Container(
                        //               margin: EdgeInsets.symmetric(vertical: 2),
                        //               padding: EdgeInsets.symmetric(
                        //                   horizontal: 10, vertical: 10),
                        //               decoration: BoxDecoration(
                        //                   color: (currentMessage.sender ==
                        //                           widget.userModal.uid)
                        //                       ? Theme.of(context)
                        //                           .colorScheme
                        //                           .secondary
                        //                       : Colors.grey,
                        //                   borderRadius:
                        //                       BorderRadius.circular(10)),
                        //               child: Text(
                        //                 currentMessage.text.toString(),
                        //                 style: TextStyle(color: Colors.white),
                        //               )),
                        //         ],
                        //       );
                        //     });
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              "An error occured please check your internet connection "),
                        );
                      } else {
                        return Center(
                          child: Text("Say hi to your new friend!"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            )),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200],
              ),
              //color: Colors.grey[200],
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.grey,
                      )),
                  // Icon(Icons.emoji_emotions)
                  Flexible(
                      child: TextField(
                    controller: messageController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "Enter Message",
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        color: Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {
                        //Icon(Icons.done_all);
                        sendMessage();
                        //Icon(Icons.done_all);
                      },
                      icon: Icon(Icons.send,
                          color: const Color.fromARGB(255, 4, 92, 7)))
                ],
              ),
              // decoration:
              //     BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            )
          ],
        ),
      )),
    );
  }

  void clearChat() async {
    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .where("sender",
            isNotEqualTo: widget
                .userModal.uid) // Only get messages sent by the current user
        .get();

    for (QueryDocumentSnapshot messageSnapshot in messagesSnapshot.docs) {
      await messageSnapshot.reference.delete();
    }
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .set({"lastmessage": "User's messages cleared"},
            SetOptions(merge: true));

    Navigator.pop(context); // Close the dialog
  }
  // void clearChat() async {
  //   QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .doc(widget.chatroom.chatroomid)
  //       .collection("messages")
  //       .where("sender",
  //           isNotEqualTo: widget
  //               .userModal.uid) // Only get messages sent by the current user
  //       .get();

  //   for (QueryDocumentSnapshot messageSnapshot in messagesSnapshot.docs) {
  //     await messageSnapshot.reference.delete();
  //   }
  //   await FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .doc(widget.chatroom.chatroomid)
  //       .set({"lastmessage": "User's messages cleared"},
  //           SetOptions(merge: true));

  //   Navigator.pop(context); // Close the dialog
  // }
}
